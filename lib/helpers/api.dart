import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const hostUrl = "https://cabinet.cashbek.uz";

BaseOptions options = BaseOptions(
  baseUrl: hostUrl,
  receiveDataWhenStatusError: true,
  connectTimeout: 20 * 1000, // 10 seconds
  receiveTimeout: 20 * 1000, // 10 seconds
);
var dio = Dio(options);

Future get(String url, {payload}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(hostUrl + url);
  try {
    final response = await dio.get(hostUrl + url,
        queryParameters: payload,
        options: Options(headers: {
          // "authorization":
          //     "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJ0ZXN0bWQiLCJzY29wZSI6WyJvcGVuaWQiXSwiZXhwIjoxNjQ2MjY5NDExLCJpYXQiOjE2NDYxODMwMTEsImF1dGhvcml0aWVzIjpbIlJPTEVfQlVTSU5FU1NfT1dORVIiXSwianRpIjoiTGpaeWRaY3RrYW9za2J6UXBuY2N3bHBRNVJVIiwiY2xpZW50X2lkIjoid2ViX2FwcCJ9.Gg2AIXgkHpDB_UZEnTtP3hWeeR5M3fddrgpTaC18OcoPvgNTnxXddiM1q40J89yfQbB70kkihOFlxxhwdaTRToP0tFZU7RXNAxggAk2VFp7zJ5O6gMtiKwc276trqJsdasRWANFIYv3ouOy3t6x4Rr-ivzGYYHmgdXaeSnTAWcaVuDYGYd-gqliWlYO09mXRpOTNq71JATJBnKbo2ZNjWWZcKZDlvTsHSKIIgyuj9Oe_5yZKHC_Q4uBHbXsSV3mPFnTEtJTpxFHkyufRZFgmgLuwFjvecYMf13Qmer1Iy_6QUshYvaoPeVdhTFxU3Tiw9D_w_zhLXVMQt_gL9A59JQ"
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    print(response.data);
    return response.data;
  } on DioError catch (e) {
    print(e.response?.statusCode);
  }
}

Future post(String url, dynamic payload) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // print(payload);
  try {
    final response = await dio.post(hostUrl + url,
        data: payload,
        options: Options(headers: {
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    return response.data;
  } on DioError catch (e) {
    print(e.response?.statusCode);
    //print(e.response?.data);
    if (e.response?.statusCode == 400) {
      return;
    }
  }
}

Future guestPost(String url, dynamic payload) async {
  try {
    final response = await dio.post(hostUrl + url, data: payload);
    // Get.snackbar('Успешно', 'Операция выполнена успешно');
    return response.data;
  } on DioError catch (e) {
    if (e.response?.statusCode == 400) {
      print(e.response?.statusCode);
      return;
    }
    if (e.response?.statusCode == 401) {
      print(e.response?.statusCode);
    }
  }
}
