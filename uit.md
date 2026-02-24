### Encode info

- Encode
  ```sh
  $ id='23520161'
  $ password='stealme'
  $ echo -n "3sn@fah.${id}:${password}" | base64
  M3Nuaslsadf...
  ```
- Save -> "encoded_info"

### Get token

- Send request

  ```http
  # Config
  @encoded_info = M3Nuaslsadf...

  ### Request
  POST /v2/stc/generate HTTP/1.1
  content-type: application/json; charset=utf-8
  authorization: UitAu {{encoded_info}}
  host: apiservice.uit.edu.vn

  {}

  ### Response
  HTTP/1.1 200 OK
  server: nginx/1.18.0 (Ubuntu)
  date: Sun, 02 Feb 2025 18:15:40 GMT
  content-type: application/json
  transfer-encoding: chunked
  expires: Sun, 19 Nov 1978 05:00:00 GMT
  cache-control: no-cache, must-revalidate
  x-content-type-options: nosniff
  vary: Accept
  set-cookie: SSESSbb01d9a0f90d4363b1d5ca1a35c4c20b=QCKO0mdaWhDgWmSr0tP4GEjkGuolR1q_4pomFGDC-SU; expires=Tue, 25-Feb-2025 21:49:00 GMT; Max-Age=2000000; path=/; domain=.apiservice.uit.edu.vn; secure; HttpOnly

  {"expires":"2025-03-05T01:15:40+0700","token":"2783.67f4c57f.emgXFj-0239DFVc3WkLe8e3M8Dr5TrAVYpCangxKmhs"}
  ```

- Save the token from server's response -> "token"

### Encode token

- Encode
  ```sh
  $ token='2783.67f4c57f.emgXFj-0239DFVc3WkLe8e3M8Dr5TrAVYpCangxKmhs'
  $ echo -n "3sn@fah.${token}:" | base64
  M3NuQGZhaC4yNzgzLjY3ZjRjNTdmLmVtZ1hGai0wMjM5REZWYzNXa0xlOGUzTThEcjVUckFWWXBDYW5neEttaHM=
  ```
- Save -> "encoded_token"

### Get info

```http
# Config
@encoded_token = M3NuQGZhaC4yNzgzLjY3ZjRjNTdmLmVtZ1hGai0wMjM5REZWYzNXa0xlOGUzTThEcjVUckFWWXBDYW5neEttaHM=

### Get info
GET /v2/data?task=current HTTP/1.1
content-type: application/json
authorization: UitAu {{encoded_token}}
host: apiservice.uit.edu.vn

### Response
HTTP/1.1 200 OK
server: nginx/1.18.0 (Ubuntu)
date: Sun, 02 Feb 2025 18:15:41 GMT
content-type: application/json
transfer-encoding: chunked
expires: Sun, 19 Nov 1978 05:00:00 GMT
cache-control: no-cache, must-revalidate
x-content-type-options: nosniff
vary: Accept
set-cookie: SSESSbb01d9a0f90d4363b1d5ca1a35c4c20b=Cyr83hWtcZdcqV9vj1BzXopSphuAYmmQrIjO0hibRmI; expires=Tue, 25-Feb-2025 21:49:01 GMT; Max-Age=2000000; path=/; domain=.apiservice.uit.edu.vn; secure; HttpOnly

{"name":"...","sid":"23520161","mail":"23520161@gm.uit.edu.vn","status":"1","course":"18","major":"K\u1ef9 thu\u1eadt Ph\u1ea7n m\u1ec1m (D480103)","dob":"25/09/1000","role":"SV","class":"KTPM2023.1","address":"...","avatar":"e430bbccc10"}
```

### Get courses

```http
# Config
@encoded_token = M3NuQGZhaC4yNzgzLjY3ZjRjNTdmLmVtZ1hGai0wMjM5REZWYzNXa0xlOGUzTThEcjVUckFWWXBDYW5neEttaHM=

### Get info
GET /v2/data?task=all&v=1 HTTP/1.1
content-type: application/json
authorization: UitAu {{encoded_token}}
host: apiservice.uit.edu.vn

### Response
HTTP/1.1 200 OK
server: nginx/1.18.0 (Ubuntu)
date: Sun, 02 Feb 2025 18:15:41 GMT
content-type: application/json
transfer-encoding: chunked
expires: Sun, 19 Nov 1978 05:00:00 GMT
cache-control: no-cache, must-revalidate
x-content-type-options: nosniff
vary: Accept
set-cookie: SSESSbb01d9a0f90d4363b1d5ca1a35c4c20b=Cyr83hWtcZdcqV9vj1BzXopSphuAYmmQrIjO0hibRmI; expires=Tue, 25-Feb-2025 21:49:01 GMT; Max-Age=2000000; path=/; domain=.apiservice.uit.edu.vn; secure; HttpOnly

{"courses":[{"name":"2","course":[{"id":999,"malop":"Demo","phonghoc":"P.A333","magv":null,"khoaql":"DHCNTT","thu":"3","tiet":"12345"}]}],"scores":[{"name":"\u0110i\u1ec3m: HK 1, NH 2023-2024","score":[{"mamh":"CS005","malop":"CS005.O12","diem":"9.7","diem1":"10","diem2":null,"diem3":null,"diem4":"9.5","heso1":"0.3","heso2":"0","heso3":"0","heso4":"0.7","hocky":"1","namhoc":"2023","sotc":"1","tenmh":"Gi\u1edbi\u00a0thi\u1ec7u\u00a0ng\u00e0nh\u00a0Khoa h\u1ecdc M\u00e1y t\u00ednh","loaimh":"\u0110C"},{"mamh":"ENG01","malop":"ENG01.2023.1.M","diem":"0","diem1":null,"diem2":null,"diem3":null,"diem4":null,"heso1":"0","heso2":"0","heso3":"0","heso4":"0","hocky":"1","namhoc":"2023","sotc":"4","tenmh":"Anh v\u0103n 1","loaimh":"\u0110C"},{"mamh":"ENG02","malop":"ENG02.2023.1.M","diem":"0","diem1":null,"diem2":null,"diem3":null,"diem4":null,"heso1":"0","heso2":"0","heso3":"0","heso4":"0","hocky":"1","namhoc":"2023","sotc":"4","tenmh":"Anh v\u0103n 2","loaimh":"\u0110C"},{"mamh":"ENG03","malop":"ENG03.O121","diem":"8.1","diem1":"9.5","diem2":null,"diem3":null,"diem4":"7.5","heso1":"0.3","heso2":"0","heso3":"0","heso4":"0.7","hocky":"1","namhoc":"2023","sotc":"4","tenmh":"Anh v\u0103n 3","loaimh":"\u0110C"},{"mamh":"IT001","malop":"IT001.O13","diem":"9.4","diem1":"10","diem2":"10","diem3":null,"diem4":"8.5","heso1":"0.2","heso2":"0.4","heso3":"0","heso4":"0.4","hocky":"1","namhoc":"2023","sotc":"4","tenmh":"Nh\u1eadp m\u00f4n l\u1eadp tr\u00ecnh","loaimh":"\u0110C"},{"mamh":"MA003","malop":"MA003.O14","diem":"8.6","diem1":"9.5","diem2":null,"diem3":"9.5","diem4":"8","heso1":"0.2","heso2":"0","heso3":"0.2","heso4":"0.6","hocky":"1","namhoc":"2023","sotc":"3","tenmh":"\u0110\u1ea1i s\u1ed1 tuy\u1ebfn t\u00ednh","loaimh":"\u0110C"},{"mamh":"MA006","malop":"MA006.O13","diem":"9.6","diem1":"10","diem2":null,"diem3":"9.5","diem4":"9.5","heso1":"0.2","heso2":"0","heso3":"0.2","heso4":"0.6","hocky":"1","namhoc":"2023","sotc":"4","tenmh":"Gi\u1ea3i t\u00edch","loaimh":"\u0110C"},{"mamh":"SS006","malop":"SS006.O111","diem":"8","diem1":null,"diem2":null,"diem3":"9.5","diem4":"7","heso1":"0","heso2":"0","heso3":"0.4","heso4":"0.6","hocky":"1","namhoc":"2023","sotc":"2","tenmh":"Ph\u00e1p lu\u1eadt \u0111\u1ea1i c\u01b0\u01a1ng","loaimh":"\u0110C"}]},{"name":"\u0110i\u1ec3m: HK 2, NH 2023-2024","score":[{"mamh":"IT002","malop":"IT002.O216","diem":"6.6","diem1":"9","diem2":"7.5","diem3":null,"diem4":"5","heso1":"0.2","heso2":"0.3","heso3":"0","heso4":"0.5","hocky":"2","namhoc":"2023","sotc":"4","tenmh":"L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng","loaimh":"CSNN"},{"mamh":"IT003","malop":"IT003.O24","diem":"8.8","diem1":"9","diem2":"9","diem3":null,"diem4":"8.5","heso1":"0.2","heso2":"0.4","heso3":"0","heso4":"0.4","hocky":"2","namhoc":"2023","sotc":"4","tenmh":"C\u1ea5u tr\u00fac d\u1eef li\u1ec7u v\u00e0 gi\u1ea3i thu\u1eadt","loaimh":"CSNN"},{"mamh":"IT012","malop":"IT012.O21","diem":"9.6","diem1":"9","diem2":"9.5","diem3":"10","diem4":"9.5","heso1":"0.1","heso2":"0.2","heso3":"0.2","heso4":"0.5","hocky":"2","namhoc":"2023","sotc":"4","tenmh":"T\u1ed5 ch\u1ee9c v\u00e0 C\u1ea5u tr\u00fac M\u00e1y t\u00ednh II","loaimh":"CSNN"},{"mamh":"MA004","malop":"MA004.O26","diem":"9.7","diem1":"10","diem2":null,"diem3":"10","diem4":"9.5","heso1":"0.2","heso2":"0","heso3":"0.2","heso4":"0.6","hocky":"2","namhoc":"2023","sotc":"4","tenmh":"C\u1ea5u tr\u00fac r\u1eddi r\u1ea1c","loaimh":"\u0110C"},{"mamh":"MA005","malop":"MA005.O220","diem":"9.8","diem1":"9","diem2":null,"diem3":"10","diem4":"10","heso1":"0.2","heso2":"0","heso3":"0.2","heso4":"0.6","hocky":"2","namhoc":"2023","sotc":"3","tenmh":"X\u00e1c su\u1ea5t th\u1ed1ng k\u00ea","loaimh":"\u0110C"},{"mamh":"SS009","malop":"SS009.O23","diem":"7.5","diem1":"8","diem2":null,"diem3":null,"diem4":"7","heso1":"0.5","heso2":"0","heso3":"0","heso4":"0.5","hocky":"2","namhoc":"2023","sotc":"2","tenmh":"Ch\u1ee7 ngh\u0129a x\u00e3 h\u1ed9i khoa h\u1ecdc","loaimh":"\u0110C"}]},{"name":"\u0110i\u1ec3m: HK 1, NH 2024-2025","score":[{"mamh":"IT004","malop":"IT004.P120","diem":"8.8","diem1":null,"diem2":"8.5","diem3":"8.5","diem4":"9","heso1":"0","heso2":"0.3","heso3":"0.2","heso4":"0.5","hocky":"1","namhoc":"2024","sotc":"4","tenmh":"C\u01a1 s\u1edf d\u1eef li\u1ec7u","loaimh":"CSNN"},{"mamh":"IT005","malop":"IT005.P13","diem":null,"diem1":null,"diem2":"9.5","diem3":"8","diem4":"8.5","heso1":"0","heso2":"0.25","heso3":"0.2","heso4":"0.4","hocky":"1","namhoc":"2024","sotc":"4","tenmh":"Nh\u1eadp m\u00f4n m\u1ea1ng m\u00e1y t\u00ednh","loaimh":"CSNN"},{"mamh":"IT007","malop":"IT007.P19","diem":null,"diem1":"10","diem2":"8.5","diem3":"9","diem4":null,"heso1":"0.15","heso2":"0.2","heso3":"0.15","heso4":"0","hocky":"1","namhoc":"2024","sotc":"4","tenmh":"H\u1ec7 \u0111i\u1ec1u h\u00e0nh","loaimh":"CSNN"},{"mamh":"SS007","malop":"SS007.P16","diem":null,"diem1":"10","diem2":null,"diem3":null,"diem4":null,"heso1":"0.5","heso2":"0","heso3":"0","heso4":"0","hocky":"1","namhoc":"2024","sotc":"3","tenmh":"Tri\u1ebft h\u1ecdc M\u00e1c \u2013 L\u00eanin","loaimh":"\u0110C"}]}],"fee":[{"phaidong":"16400000","somon":"0","dkhp":null,"thoigiandong":"2025-01-05","nganhang":"BIDV","notruoc":"0","dadong":"16400000","hocky":"2","namhoc":"2024"},{"phaidong":"16400000","somon":"5","dkhp":"IT004(5.0),IT005(5.0),IT007(5.0),IT008(5.0),SS007(3.0)","thoigiandong":"2024-08-10","nganhang":"BIDV","notruoc":"0","dadong":"16400000","hocky":"1","namhoc":"2024"},{"phaidong":"14500000","somon":"6","dkhp":"IT002(5.0),IT003(5.0),IT012(5.0),MA004(4.0),MA005(3.0),SS009(2.0)","thoigiandong":"2024-01-11","nganhang":"BIDV","notruoc":"-1500000","dadong":"13000000","hocky":"2","namhoc":"2023"},{"phaidong":"14670100","somon":"0","dkhp":"","thoigiandong":"2023-09-04","nganhang":"BIDV","notruoc":"0","dadong":"16170100","hocky":"1","namhoc":"2023"}],"notify":[{"id":"1951372","title":"Th\u00f4ng b\u00e1o h\u1ecdc ph\u00ed","sid":"23520161","content":"Ch\u00e0o sinh vi\u00ean Tr\u1ea7n Nguy\u1ec5n Th\u00e1i B\u00ecnh (23520161), Ph\u00f2ng KHTC \u0111\u00e3 nh\u1eadn \u0111\u01b0\u1ee3c s\u1ed1 ti\u1ec1n thanh to\u00e1n h\u1ecdc ph\u00ed h\u1ecdc k\u1ef3 2/2024 l\u00e0: 16,400,000 VN\u0110, A/C vui l\u00f2ng \u0111\u0103ng nh\u1eadp v\u00e0o c\u1ed5ng th\u00f4ng tin \u0111\u1ec3 xem chi ti\u1ebft.","type":"HP","member":"SV","dated":"2025-01-05 19:55:19","hocky":"1","namhoc":"2024"},{"id":"1945722","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT005.P13(Nh\u1eadp m\u00f4n m\u1ea1ng m\u00e1y t\u00ednh)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 22521214 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc Nh\u1eadp m\u00f4n m\u1ea1ng m\u00e1y t\u00ednh(IT005.P13) v\u00e0o th\u1ee9 2 ng\u00e0y 30 th\u00e1ng 12 n\u0103m 2024, Ti\u1ebft 1,2,3, Ph\u00f2ng B6.10.","type":"BB","member":"SV","dated":"2024-12-29 11:10:32","hocky":"1","namhoc":"2024"},{"id":"1845428","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT004.P120(C\u01a1 s\u1edf d\u1eef li\u1ec7u)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 22520172 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc C\u01a1 s\u1edf d\u1eef li\u1ec7u(IT004.P120) v\u00e0o th\u1ee9 6 ng\u00e0y 06 th\u00e1ng 12 n\u0103m 2024, Ti\u1ebft 6,7,8,9, Ph\u00f2ng B5.10.","type":"BB","member":"SV","dated":"2024-11-21 10:35:22","hocky":"1","namhoc":"2024"},{"id":"1825910","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT007.P19(H\u1ec7 \u0111i\u1ec1u h\u00e0nh)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 20520888 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc H\u1ec7 \u0111i\u1ec1u h\u00e0nh(IT007.P19) v\u00e0o th\u1ee9 5 ng\u00e0y 05 th\u00e1ng 12 n\u0103m 2024, Ti\u1ebft 2,3,4,5, Ph\u00f2ng B6.10.","type":"BB","member":"SV","dated":"2024-11-18 08:16:59","hocky":"1","namhoc":"2024"},{"id":"1813798","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT008.P13(L\u1eadp tr\u00ecnh tr\u1ef1c quan)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 21522144 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc L\u1eadp tr\u00ecnh tr\u1ef1c quan(IT008.P13) v\u00e0o th\u1ee9 4 ng\u00e0y 04 th\u00e1ng 12 n\u0103m 2024, Ti\u1ebft 6,7,8,9, Ph\u00f2ng C309.","type":"BB","member":"SV","dated":"2024-11-14 08:59:10","hocky":"1","namhoc":"2024"},{"id":"1770368","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc IT004.P120(C\u01a1 s\u1edf d\u1eef li\u1ec7u)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n C\u01a1 s\u1edf d\u1eef li\u1ec7u(IT004.P120) v\u00e0o th\u1ee9 6 ng\u00e0y 08 th\u00e1ng 11 n\u0103m 2024.","type":"BN","member":"SV","dated":"2024-11-06 13:56:02","hocky":"1","namhoc":"2024"},{"id":"1745223","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc IT008.P13(L\u1eadp tr\u00ecnh tr\u1ef1c quan)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n L\u1eadp tr\u00ecnh tr\u1ef1c quan(IT008.P13) v\u00e0o th\u1ee9 4 ng\u00e0y 06 th\u00e1ng 11 n\u0103m 2024.","type":"BN","member":"SV","dated":"2024-10-29 13:21:59","hocky":"1","namhoc":"2024"},{"id":"1573731","title":"Th\u00f4ng b\u00e1o h\u1ecdc ph\u00ed","sid":"23520161","content":"Ch\u00e0o sinh vi\u00ean Tr\u1ea7n Nguy\u1ec5n Th\u00e1i B\u00ecnh (23520161), Ph\u00f2ng KHTC \u0111\u00e3 nh\u1eadn \u0111\u01b0\u1ee3c s\u1ed1 ti\u1ec1n thanh to\u00e1n h\u1ecdc ph\u00ed h\u1ecdc k\u1ef3 1/2024 l\u00e0: 16,400,000 VN\u0110, A/C vui l\u00f2ng \u0111\u0103ng nh\u1eadp v\u00e0o c\u1ed5ng th\u00f4ng tin \u0111\u1ec3 xem chi ti\u1ebft.","type":"HP","member":"SV","dated":"2024-08-10 20:51:48","hocky":"3","namhoc":"2023"},{"id":"1560939","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT002.O216(L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520161 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng(IT002.O216) v\u00e0o th\u1ee9 5 ng\u00e0y 13 th\u00e1ng 06 n\u0103m 2024, Ti\u1ebft 6,7,8, Ph\u00f2ng B1.22.","type":"BB","member":"SV","dated":"2024-06-10 11:19:46","hocky":"2","namhoc":"2023"},{"id":"1559353","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT002.O216(L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520161 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng(IT002.O216) v\u00e0o th\u1ee9 3 ng\u00e0y 11 th\u00e1ng 06 n\u0103m 2024, Ti\u1ebft 8,9,10, Ph\u00f2ng B1.16.","type":"BB","member":"SV","dated":"2024-06-08 11:59:43","hocky":"2","namhoc":"2023"},{"id":"1509449","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc IT002.O216(L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng(IT002.O216) v\u00e0o th\u1ee9 5 ng\u00e0y 16 th\u00e1ng 05 n\u0103m 2024.","type":"BN","member":"SV","dated":"2024-05-16 10:03:56","hocky":"2","namhoc":"2023"},{"id":"1507077","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT003.O24.1(C\u1ea5u tr\u00fac d\u1eef li\u1ec7u v\u00e0 gi\u1ea3i thu\u1eadt)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520161 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc C\u1ea5u tr\u00fac d\u1eef li\u1ec7u v\u00e0 gi\u1ea3i thu\u1eadt(IT003.O24.1) v\u00e0o th\u1ee9 2 ng\u00e0y 03 th\u00e1ng 06 n\u0103m 2024, Ti\u1ebft 1,2,3,4,5, Ph\u00f2ng B2.06.","type":"BB","member":"SV","dated":"2024-05-16 08:57:09","hocky":"2","namhoc":"2023"},{"id":"1481347","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc MA005.O220(X\u00e1c su\u1ea5t th\u1ed1ng k\u00ea)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 20520210 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc X\u00e1c su\u1ea5t th\u1ed1ng k\u00ea(MA005.O220) v\u00e0o th\u1ee9 6 ng\u00e0y 17 th\u00e1ng 05 n\u0103m 2024, Ti\u1ebft 6,7,8,9, Ph\u00f2ng B4.20.","type":"BB","member":"SV","dated":"2024-05-11 11:25:00","hocky":"2","namhoc":"2023"},{"id":"1450767","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc MA004.O26(C\u1ea5u tr\u00fac r\u1eddi r\u1ea1c)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 22521678 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc C\u1ea5u tr\u00fac r\u1eddi r\u1ea1c(MA004.O26) v\u00e0o th\u1ee9 3 ng\u00e0y 11 th\u00e1ng 06 n\u0103m 2024, Ti\u1ebft 1,2,3,4,5, Ph\u00f2ng B3.18.","type":"BB","member":"SV","dated":"2024-05-06 10:13:12","hocky":"2","namhoc":"2023"},{"id":"1417162","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT003.O24(C\u1ea5u tr\u00fac d\u1eef li\u1ec7u v\u00e0 gi\u1ea3i thu\u1eadt)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520161 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc C\u1ea5u tr\u00fac d\u1eef li\u1ec7u v\u00e0 gi\u1ea3i thu\u1eadt(IT003.O24) v\u00e0o th\u1ee9 7 ng\u00e0y 04 th\u00e1ng 05 n\u0103m 2024, Ti\u1ebft 4,5,6, Ph\u00f2ng B3.20.","type":"BB","member":"SV","dated":"2024-04-26 15:59:36","hocky":"2","namhoc":"2023"},{"id":"1382348","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc IT002.O216(L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n L\u1eadp tr\u00ecnh h\u01b0\u1edbng \u0111\u1ed1i t\u01b0\u1ee3ng(IT002.O216) v\u00e0o th\u1ee9 5 ng\u00e0y 11 th\u00e1ng 04 n\u0103m 2024.","type":"BN","member":"SV","dated":"2024-04-11 11:44:17","hocky":"2","namhoc":"2023"},{"id":"1227742","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc MA005.O220(X\u00e1c su\u1ea5t th\u1ed1ng k\u00ea)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n X\u00e1c su\u1ea5t th\u1ed1ng k\u00ea(MA005.O220) v\u00e0o th\u1ee9 7 ng\u00e0y 24 th\u00e1ng 02 n\u0103m 2024.","type":"BN","member":"SV","dated":"2024-02-22 08:43:51","hocky":"1","namhoc":"2023"},{"id":"1183962","title":"Th\u00f4ng b\u00e1o h\u1ecdc ph\u00ed","sid":"23520161","content":"Ch\u00e0o sinh vi\u00ean Tr\u1ea7n Nguy\u1ec5n Th\u00e1i B\u00ecnh (23520161), Ph\u00f2ng KHTC \u0111\u00e3 nh\u1eadn \u0111\u01b0\u1ee3c s\u1ed1 ti\u1ec1n thanh to\u00e1n h\u1ecdc ph\u00ed h\u1ecdc k\u1ef3 2/2023 l\u00e0: 13,000,000 VN\u0110, A/C vui l\u00f2ng \u0111\u0103ng nh\u1eadp v\u00e0o c\u1ed5ng th\u00f4ng tin \u0111\u1ec3 xem chi ti\u1ebft.","type":"HP","member":"SV","dated":"2024-01-11 12:00:13","hocky":"1","namhoc":"2023"},{"id":"1175797","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc IT001.O13.1(Nh\u1eadp m\u00f4n l\u1eadp tr\u00ecnh)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520016 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc Nh\u1eadp m\u00f4n l\u1eadp tr\u00ecnh(IT001.O13.1) v\u00e0o th\u1ee9 5 ng\u00e0y 04 th\u00e1ng 01 n\u0103m 2024, Ti\u1ebft 6,7,8,9,10, Ph\u00f2ng B2.02.","type":"BB","member":"SV","dated":"2024-01-02 08:24:44","hocky":"1","namhoc":"2023"},{"id":"1162647","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc IT001.O13.1(Nh\u1eadp m\u00f4n l\u1eadp tr\u00ecnh)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n Nh\u1eadp m\u00f4n l\u1eadp tr\u00ecnh(IT001.O13.1) v\u00e0o th\u1ee9 2 ng\u00e0y 25 th\u00e1ng 12 n\u0103m 2023.","type":"BN","member":"SV","dated":"2023-12-25 13:31:15","hocky":"1","namhoc":"2023"},{"id":"1142817","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc MA006.O13(Gi\u1ea3i t\u00edch)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520016 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc Gi\u1ea3i t\u00edch(MA006.O13) v\u00e0o th\u1ee9 5 ng\u00e0y 04 th\u00e1ng 01 n\u0103m 2024, Ti\u1ebft 1,2,3,4,5, Ph\u00f2ng B1.18.","type":"BB","member":"SV","dated":"2023-12-15 13:59:54","hocky":"1","namhoc":"2023"},{"id":"1047357","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc MA006.O13(Gi\u1ea3i t\u00edch)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n Gi\u1ea3i t\u00edch(MA006.O13) v\u00e0o th\u1ee9 4 ng\u00e0y 22 th\u00e1ng 11 n\u0103m 2023.","type":"BN","member":"SV","dated":"2023-11-22 06:00:32","hocky":"1","namhoc":"2023"},{"id":"1027232","title":"[TB] - H\u1ecdc b\u00f9 m\u00f4n h\u1ecdc ENG03.O121(Anh v\u0103n 3)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1o \u0111\u1ebfn sinh vi\u00ean 23520161 l\u1ecbch h\u1ecdc b\u00f9 m\u00f4n h\u1ecdc Anh v\u0103n 3(ENG03.O121) v\u00e0o th\u1ee9 3 ng\u00e0y 09 th\u00e1ng 01 n\u0103m 2024, Ti\u1ebft 1,2,3, Ph\u00f2ng C216.","type":"BB","member":"SV","dated":"2023-11-17 14:29:25","hocky":"1","namhoc":"2023"},{"id":"1025897","title":"[TB] - Ngh\u1ec9 m\u00f4n h\u1ecdc ENG03.O121(Anh v\u0103n 3)","sid":"23520161","content":"Tr\u01b0\u1eddng \u0110H CNTT th\u00f4ng b\u00e1ongh\u1ec9 h\u1ecdc M\u00f4n Anh v\u0103n 3(ENG03.O121) v\u00e0o th\u1ee9 7 ng\u00e0y 18 th\u00e1ng 11 n\u0103m 2023.","type":"BN","member":"SV","dated":"2023-11-17 10:50:02","hocky":"1","namhoc":"2023"},{"id":"959686","title":"Th\u00f4ng b\u00e1o h\u1ecdc ph\u00ed","sid":"23520161","content":"Ch\u00e0o sinh vi\u00ean Tr\u1ea7n Nguy\u1ec5n Th\u00e1i B\u00ecnh (23520161), Ph\u00f2ng KHTC \u0111\u00e3 nh\u1eadn \u0111\u01b0\u1ee3c s\u1ed1 ti\u1ec1n thanh to\u00e1n h\u1ecdc ph\u00ed h\u1ecdc k\u1ef3 1/2023 l\u00e0: 16,170,100 VN\u0110, A/C vui l\u00f2ng \u0111\u0103ng nh\u1eadp v\u00e0o c\u1ed5ng th\u00f4ng tin \u0111\u1ec3 xem chi ti\u1ebft.","type":"HP","member":"SV","dated":"2023-09-04 19:47:08","hocky":"1","namhoc":"2023"},{"id":"26821","title":"Th\u00f4ng b\u00e1o c\u1eadp nh\u1eadt \u1ee8ng d\u1ee5ng!","sid":"ALL","content":"Anh/Ch\u1ecb vui l\u00f2ng c\u1eadp nh\u1eadt \u1ee9ng d\u1ee5ng tr\u00ean Android, \u0111\u1ec3 \u0111i\u1ec3m danh, vui l\u00f2ng: B\u1eadt Location, C\u1ea5p quy\u1ec1n Access Location, Quy\u1ec1n Get device information, s\u1eed d\u1ee5ng wifi UIT, UIT Public","type":"ALL","member":"ALL","dated":"2019-04-19 14:00:00","hocky":null,"namhoc":null},{"id":"4414","title":"Th\u00f4ng b\u00e1o t\u1eeb UIT t\u1edbi SV","sid":"ALL","content":"Anh Minh g\u1edfi ki\u1ec3m tra!","type":"ALL","member":"ALL","dated":"2019-03-13 15:00:21","hocky":null,"namhoc":null}],"offday":null,"makeup":null,"deadline":[{"id":"334851","username":"23520161","shortname":"IT005.P13","name":"\u0110I\u1ec3m Th\u1ef1c h\u00e0nh","duedate":"1737738000","niceDate":"25/01/2025 00:00:00","closed":"1","status":null},{"id":"334497","username":"23520161","shortname":"IT004.P120","name":"T\u1ed5ng H\u1ee3p B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh (B\u1eaft bu\u1ed9c)","duedate":"1736960400","niceDate":"16/01/2025 00:00:00","closed":"1","status":"submitted"},{"id":"325627","username":"23520161","shortname":"IT008.P13","name":"N\u1ed8P TO\u00c0N V\u0102N B\u00c1O C\u00c1O - NG\u00c0Y 4-01-25","duedate":"1736956800","niceDate":"15/01/2025 23:00:00","closed":"1","status":"submitted"},{"id":"332042","username":"23520161","shortname":"IT004.P120","name":"B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh Tu\u1ea7n 5","duedate":"1736010000","niceDate":"05/01/2025 00:00:00","closed":"1","status":"submitted"},{"id":"317555","username":"23520161","shortname":"IT004.P120","name":"B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh Tu\u1ea7n 4","duedate":"1735923600","niceDate":"04/01/2025 00:00:00","closed":"1","status":"submitted"},{"id":"325657","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i v\u1ec1 nh\u00e0 ch\u01b0\u01a1ng 9. L\u1eadp tr\u00ecnh WPF","duedate":"1735858800","niceDate":"03/01/2025 06:00:00","closed":"1","status":"new"},{"id":"333267","username":"23520161","shortname":"IT004.P120","name":"N\u1ed9p B\u00e0i Thi Cu\u1ed1i K\u1ef3 - IT004.P120.2","duedate":"1735789800","niceDate":"02/01/2025 10:50:00","closed":"1","status":"submitted"},{"id":"333122","username":"23520161","shortname":"IT004.P120","name":"N\u1ed9p B\u00e0i Thi Cu\u1ed1i K\u1ef3 - IT004.P120.1","duedate":"1735784100","niceDate":"02/01/2025 09:15:00","closed":"1","status":"new"},{"id":"327617","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i th\u1ef1c h\u00e0nh tu\u1ea7n 5 - l\u1edbp 2","duedate":"1735081200","niceDate":"25/12/2024 06:00:00","closed":"1","status":null},{"id":"328987","username":"23520161","shortname":"IT005.P13","name":"Lab6_IT005.P13.2_16/12/2024","duedate":"1734886800","niceDate":"23/12/2024 00:00:00","closed":"1","status":"submitted"},{"id":"311945","username":"23520161","shortname":"IT004.P120","name":"B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh Tu\u1ea7n 3","duedate":"1734541200","niceDate":"19/12/2024 00:00:00","closed":"1","status":"submitted"},{"id":"329562","username":"23520161","shortname":"IT008.P13","name":"N\u1ed9p b\u00e0i thi th\u1ef1c h\u00e0nh l\u1edbp 2","duedate":"1734489900","niceDate":"18/12/2024 09:45:00","closed":"1","status":null},{"id":"325972","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 6 - L\u1edbp IT007.P19.2","duedate":"1734426000","niceDate":"17/12/2024 16:00:00","closed":"1","status":null},{"id":"327267","username":"23520161","shortname":"SS007.P16","name":"N\u1ed8P FILE THUY\u1ebeT TR\u00ccNH","duedate":"1734418800","niceDate":"17/12/2024 14:00:00","closed":"1","status":null},{"id":"326857","username":"23520161","shortname":"IT005.P13","name":"Lab6_IT005.P13.1_09/12/2024","duedate":"1734282000","niceDate":"16/12/2024 00:00:00","closed":"1","status":null},{"id":"294781","username":"23520161","shortname":"IT004.P120","name":"B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh Tu\u1ea7n 1","duedate":"1734278400","niceDate":"15/12/2024 23:00:00","closed":"1","status":"submitted"},{"id":"302626","username":"23520161","shortname":"IT004.P120","name":"B\u00e0i T\u1eadp Th\u1ef1c H\u00e0nh Tu\u1ea7n 2","duedate":"1734278400","niceDate":"15/12/2024 23:00:00","closed":"1","status":"submitted"},{"id":"327522","username":"23520161","shortname":"IT008.P13","name":"N\u1ed9p b\u00e0i thi th\u1ef1c h\u00e0nh l\u1edbp 1","duedate":"1733886600","niceDate":"11/12/2024 10:10:00","closed":"1","status":"submitted"},{"id":"325477","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i th\u1ef1c h\u00e0nh tu\u1ea7n 4 -l\u1edbp 2","duedate":"1733850000","niceDate":"11/12/2024 00:00:00","closed":"1","status":"submitted"},{"id":"324552","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 6 - L\u1edbp IT007.P19.1","duedate":"1733821200","niceDate":"10/12/2024 16:00:00","closed":"1","status":"submitted"},{"id":"324952","username":"23520161","shortname":"IT005.P13","name":"Lab5_IT005.P13.2_02/12/2024","duedate":"1733677200","niceDate":"09/12/2024 00:00:00","closed":"1","status":"submitted"},{"id":"321835","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 3 - l\u1edbp 2","duedate":"1733245200","niceDate":"04/12/2024 00:00:00","closed":"1","status":"new"},{"id":"322575","username":"23520161","shortname":"IT008.P13","name":"N\u1ed9p c\u00e1c b\u00e0i t\u1eadp c\u00f2n thi\u1ebfu (b\u00e0i t\u1eadp v\u1ec1 nh\u00e0 tr\u00ean l\u1edbp - B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh)","duedate":"1732986000","niceDate":"01/12/2024 00:00:00","closed":"1","status":"new"},{"id":"323010","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 4 - L\u1edbp IT007.P19.2","duedate":"1732957200","niceDate":"30/11/2024 16:00:00","closed":"1","status":"new"},{"id":"319235","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 5 - l\u1edbp 1","duedate":"1732662000","niceDate":"27/11/2024 06:00:00","closed":"1","status":"submitted"},{"id":"319705","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i t\u1eadp ch\u01b0\u01a1ng 6","duedate":"1732118400","niceDate":"20/11/2024 23:00:00","closed":"1","status":"submitted"},{"id":"317015","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 3 - L\u1edbp IT007.P19.2","duedate":"1731747600","niceDate":"16/11/2024 16:00:00","closed":"1","status":"new"},{"id":"312955","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 4 - l\u1edbp 1","duedate":"1731452400","niceDate":"13/11/2024 06:00:00","closed":"1","status":"submitted"},{"id":"315450","username":"23520161","shortname":"IT005.P13","name":"Lab3_IT005.P13.2_04/11/2024","duedate":"1731258000","niceDate":"11/11/2024 00:00:00","closed":"1","status":"submitted"},{"id":"314130","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 4 - L\u1edbp IT007.P19.1","duedate":"1731229200","niceDate":"10/11/2024 16:00:00","closed":"1","status":"submitted"},{"id":"314270","username":"23520161","shortname":"IT008.P13","name":"L\u1ecbnk review \u0110\u1ed3 \u00e1n!","duedate":"1730912400","niceDate":"07/11/2024 00:00:00","closed":"1","status":"new"},{"id":"312315","username":"23520161","shortname":"IT005.P13","name":"Lab5_IT005.P13.1_28/10/2024","duedate":"1730653200","niceDate":"04/11/2024 00:00:00","closed":"1","status":"new"},{"id":"308890","username":"23520161","shortname":"IT008.P13","name":"N\u1ed8P B\u00c1O C\u00c1O GI\u1eeeA K\u1ef2","duedate":"1730502000","niceDate":"02/11/2024 06:00:00","closed":"1","status":"submitted"},{"id":"308880","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 Ch\u01b0\u01a1ng 5-Ph\u1ea7n 2, Ch\u01b0\u01a1ng 6","duedate":"1730242800","niceDate":"30/10/2024 06:00:00","closed":"1","status":"new"},{"id":"308440","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 3 - L\u1edbp 1","duedate":"1730221200","niceDate":"30/10/2024 00:00:00","closed":"1","status":"new"},{"id":"309510","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 3 - L\u1edbp IT007.P19.1","duedate":"1730019600","niceDate":"27/10/2024 16:00:00","closed":"1","status":"submitted"},{"id":"304341","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 2 - L\u1edbp 2","duedate":"1729616400","niceDate":"23/10/2024 00:00:00","closed":"1","status":"submitted"},{"id":"306866","username":"23520161","shortname":"IT005.P13","name":"Lab3_IT005.P13.1_14/10/2024","duedate":"1729443600","niceDate":"21/10/2024 00:00:00","closed":"1","status":null},{"id":"304966","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 2 - L\u1edbp IT007.P19.2","duedate":"1729328400","niceDate":"19/10/2024 16:00:00","closed":"1","status":"new"},{"id":"301341","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 2 - L\u1edbp 1","duedate":"1729033200","niceDate":"16/10/2024 06:00:00","closed":"1","status":"submitted"},{"id":"304631","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 Ch\u01b0\u01a1ng 4.3, Ch\u01b0\u01a1ng 5 Ph\u1ea7n 1","duedate":"1729033200","niceDate":"16/10/2024 06:00:00","closed":"1","status":"submitted"},{"id":"302406","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i th\u1ef1c h\u00e0nh 2 - L\u1edbp IT007.P19.1","duedate":"1728896400","niceDate":"14/10/2024 16:00:00","closed":"1","status":"submitted"},{"id":"303621","username":"23520161","shortname":"IT005.P13","name":"Lab2_IT005.P13.2_07/10/2024","duedate":"1728838800","niceDate":"14/10/2024 00:00:00","closed":"1","status":"submitted"},{"id":"298526","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 1 - l\u1edbp 2","duedate":"1728493200","niceDate":"10/10/2024 00:00:00","closed":"1","status":"new"},{"id":"301811","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 Ch\u01b0\u01a1ng 4.2","duedate":"1728428400","niceDate":"09/10/2024 06:00:00","closed":"1","status":"submitted"},{"id":"296991","username":"23520161","shortname":"IT005.P13","name":"Lab2_IT005.P13.1_30/9/2024","duedate":"1728406800","niceDate":"09/10/2024 00:00:00","closed":"1","status":"new"},{"id":"291706","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp th\u1ef1c h\u00e0nh tu\u1ea7n 1 - L\u1edbp 1","duedate":"1727823600","niceDate":"02/10/2024 06:00:00","closed":"1","status":"submitted"},{"id":"299001","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 Ch\u01b0\u01a1ng 3 - ch\u01b0\u01a1ng 4.1","duedate":"1727823600","niceDate":"02/10/2024 06:00:00","closed":"1","status":"submitted"},{"id":"296551","username":"23520161","shortname":"IT005.P13","name":"Lab1_IT005.P13.2_23/9/2024","duedate":"1727629200","niceDate":"30/09/2024 00:00:00","closed":"1","status":"submitted"},{"id":"299486","username":"23520161","shortname":"IT007.P19","name":"N\u1ed9p b\u00e0i t\u1eadp ch\u01b0\u01a1ng 3","duedate":"1727625600","niceDate":"29/09/2024 23:00:00","closed":"1","status":"submitted"},{"id":"292766","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 ch\u01b0\u01a1ng 2 - Ph\u1ea7n 3","duedate":"1727218800","niceDate":"25/09/2024 06:00:00","closed":"1","status":"submitted"},{"id":"281924","username":"23520161","shortname":"IT005.P13","name":"Lab1_IT005.P13.1_16/9/2024","duedate":"1727024400","niceDate":"23/09/2024 00:00:00","closed":"1","status":"new"},{"id":"285266","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 ch\u01b0\u01a1ng 2 - ph\u1ea7n 2","duedate":"1726614000","niceDate":"18/09/2024 06:00:00","closed":"1","status":"submitted"},{"id":"278079","username":"23520161","shortname":"IT008.P13","name":"B\u00e0i t\u1eadp v\u1ec1 nh\u00e0 Ch\u01b0\u01a1ng 2","duedate":"1726074000","niceDate":"12/09/2024 00:00:00","closed":"1","status":"submitted"}],"exams":{"06-01-2025":{"ca2":"Ca 2(9h30): IT005.P13 (Nh\u1eadp m\u00f4n m\u1ea1ng m\u00e1y t\u00ednh), Ph\u00f2ng B4.22"},"08-01-2025":{"ca2":"Ca 2(9h30): IT004.P120 (C\u01a1 s\u1edf d\u1eef li\u1ec7u), Ph\u00f2ng B6.08"},"10-01-2025":{"ca2":"Ca 2(9h30): IT007.P19 (H\u1ec7 \u0111i\u1ec1u h\u00e0nh), Ph\u00f2ng B4.14"},"15-01-2025":{"ca3":"Ca 3(13h30): SS007.P16 (Tri\u1ebft h\u1ecdc M\u00e1c \u2013 L\u00eanin), Ph\u00f2ng B3.10"},"25-12-2024":{"ca67890":"Ca 67890(7h30): IT008.P13 (L\u1eadp tr\u00ecnh tr\u1ef1c quan), Ph\u00f2ng B1.14"}}}
```

Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "StudentDataSchema",
  "type": "object",
  "properties": {
    "courses": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string"
          },
          "course": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "integer"
                },
                "malop": {
                  "type": "string"
                },
                "phonghoc": {
                  "type": "string"
                },
                "magv": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "khoaql": {
                  "type": "string"
                },
                "thu": {
                  "type": "string"
                },
                "tiet": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    },
    "scores": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string"
          },
          "score": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "mamh": {
                  "type": "string"
                },
                "malop": {
                  "type": "string"
                },
                "diem": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "tenmh": {
                  "type": "string"
                },
                "sotc": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    },
    "fee": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "phaidong": {
            "type": "string"
          },
          "dadong": {
            "type": "string"
          },
          "hocky": {
            "type": "string"
          },
          "namhoc": {
            "type": "string"
          }
        }
      }
    },
    "notify": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "content": {
            "type": "string"
          },
          "dated": {
            "type": "string"
          }
        }
      }
    },
    "deadline": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "shortname": {
            "type": "string"
          },
          "name": {
            "type": "string"
          },
          "niceDate": {
            "type": "string"
          },
          "status": {
            "type": [
              "string",
              "null"
            ]
          }
        }
      }
    },
    "exams": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "additionalProperties": {
          "type": "string"
        }
      }
    }
  }
}
```
