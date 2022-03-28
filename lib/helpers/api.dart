import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  try {
    final response = await dio.get(hostUrl + url,
        queryParameters: payload,
        options: Options(headers: {
          // "authorization":
          //     "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJ0ZXN0bWQiLCJzY29wZSI6WyJvcGVuaWQiXSwibGFzdF9uYW1lIjpudWxsLCJleHAiOjE2NDg1MjI2OTIsImlhdCI6MTY0ODQzNjI5MiwiZmlyc3RfbmFtZSI6bnVsbCwiYXV0aG9yaXRpZXMiOlsiUk9MRV9CVVNJTkVTU19PV05FUiJdLCJqdGkiOiJzNXRiV0dyTEhLUFd4OENwa01BLWRSMTI1enMiLCJjbGllbnRfaWQiOiJ3ZWJfYXBwIiwib3duZXJMb2dpbiI6bnVsbH0.c1Oyl3ZBCkPXxX_i2x9fDUDnwAw89qRwZ6BCnO_wYtFke4z5sdsTWBeCYamNglSsZccSrhZMkqGj1L5nok60JZP1DagHGpHJ7yQW3VWlr6NQpjjhbcifwirfv_RC4uadl3OUWMh9JZlHUv8txEre_o8EZVOyUdj_mXLq0MSH9FQdOdoPL-04zoej_2HOLTDhIq4F5Ckabwt3-qKY2HDEhjJhxQR-Arm-JZzEPM89HCIPmw5cQEXUmm1xQ6VlTjXcQJvmec24Rv9n9zH4zgjALS9g34NQtReDx0PG-J24LXmxAovsGKgrODs1wTHq_mkd2IQqfqNpmvBclIetsAiu2g"
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    return response.data;
  } on DioError catch (e) {
    print(e.response?.statusCode);
    statuscheker(e);
  }
}

Future post(String url, dynamic payload) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await dio.post(hostUrl + url,
        data: payload,
        options: Options(headers: {
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    return response.data;
  } on DioError catch (e) {
    statuscheker(e);
  }
}

Future guestPost(String url, dynamic payload) async {
  try {
    final response = await dio.post(hostUrl + url, data: payload);
    // Get.snackbar('Успешно', 'Операция выполнена успешно');
    return response.data;
  } on DioError catch (e) {
    statuscheker(e);
  }
}

Future put(String url, dynamic payload) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await dio.put(hostUrl + url,
        data: payload,
        options: Options(headers: {
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    return response.data;
  } on DioError catch (e) {
    statuscheker(e);
  }
}

Future delete(String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await dio.delete(hostUrl + url,
        options: Options(headers: {
          "authorization": "Bearer ${prefs.getString('access_token')}",
        }));
    return response.data;
  } on DioError catch (e) {
    print(e.response?.statusCode);
    statuscheker(e);
  }
}

statuscheker(e) async {
  if (e.response?.statusCode == 400) {
    showErrorToast(e.message);
  }
  if (e.response?.statusCode == 401) {
    showErrorToast('Неправильный логин или пароль');
  }
  if (e.response?.statusCode == 403) {}
  if (e.response?.statusCode == 404) {
    showErrorToast('Не найдено');
  }
  if (e.response?.statusCode == 415) {
    showErrorToast('Ошибка');
  }
  if (e.response?.statusCode == 500) {
    showErrorToast(e.message);
  }
}

showErrorToast(message) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFFE32F45),
      textColor: Colors.white,
      fontSize: 16.0);
}
