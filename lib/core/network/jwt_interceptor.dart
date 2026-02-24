import 'package:dio/dio.dart';
import 'package:uit_mobile/core/storage/secure_storage_service.dart';
import 'package:uit_mobile/core/utils/constants.dart';
import 'package:uit_mobile/core/utils/encoding.dart';

/// Dio interceptor that:
/// 1. Attaches the encoded token as the `Authorization` header.
/// 2. On 401, re-authenticates using stored credentials, refreshes the token,
///    and retries the failed request transparently.
class JwtInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;

  /// Whether a token refresh is currently in progress.
  bool _isRefreshing = false;

  /// Queued requests waiting for the token refresh to complete.
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  JwtInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Attach the current encoded token if available.
    final session = await storage.getActiveSession();
    if (session?.encodedToken != null) {
      options.headers['Authorization'] =
          '$kAuthScheme ${session!.encodedToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final session = await storage.getActiveSession();
    if (session == null) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue the request until refresh completes.
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      // Step 1: Re-authenticate to get a new token.
      final freshDio = Dio(BaseOptions(baseUrl: kApiBaseUrl));
      final response = await freshDio.post(
        '/v2/stc/generate',
        data: {},
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': '$kAuthScheme ${session.encodedCredentials}',
          },
        ),
      );

      final newToken = response.data['token'] as String;
      final expiresStr = response.data['expires'] as String;
      final newEncodedToken = encodeToken(newToken);
      final expiry = DateTime.parse(expiresStr);

      // Step 2: Update stored session.
      final updatedSession = session.copyWith(
        token: newToken,
        encodedToken: newEncodedToken,
        tokenExpiry: expiry,
      );
      await storage.upsertSession(updatedSession);

      // Step 3: Retry the original request with a clean Dio (no baseUrl)
      // to avoid double-prefixing since requestOptions.path is already absolute.
      final retryDio = Dio();
      err.requestOptions.headers['Authorization'] =
          '$kAuthScheme $newEncodedToken';
      final retryResponse = await retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Step 4: Retry all queued requests.
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] =
            '$kAuthScheme $newEncodedToken';
        final r = await retryDio.fetch(pending.options);
        pending.handler.resolve(r);
      }
    } on DioException catch (e) {
      handler.next(e);
      for (final pending in _pendingRequests) {
        pending.handler.next(e);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}
