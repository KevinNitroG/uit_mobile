import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/jwt_interceptor.dart';
import 'package:uit_mobile/core/storage/secure_storage_service.dart';
import 'package:uit_mobile/core/utils/constants.dart';

/// Provider for the configured [Dio] instance.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    ),
  );

  final storageService = ref.read(secureStorageServiceProvider);
  dio.interceptors.add(JwtInterceptor(dio: dio, storage: storageService));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
