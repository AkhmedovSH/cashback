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
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    // print(response.data);
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
    //print(e.response?.statusCode);
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
