import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:simple_moment/simple_moment.dart';

// Colors

Color black = const Color(0xFF000000);
Color purple = const Color(0xFF78379B);
Color white = const Color(0xFFFFFFFF);
Color red = const Color(0xFFdc3545);
Color blue = const Color(0xFF17a2b8);
Color grey = const Color(0xFF838488);
Color lightGrey = const Color(0xFF9C9C9C);
Color borderColor = const Color(0xFFF8F8F8);

Color success = const Color(0xFF34c38f);
Color warning = const Color(0xFFf1b44c);
Color danger = const Color(0xFFf46a6a);

// Date formaters

formatDate(date) {
  // return DateFormat('dd.MM.yyyy HH:mm').format(date);
  Moment rawDate = Moment.parse(date);
  return rawDate.format("dd-MM-yyyy HH:mm");
}

formatMoney(amount) {
  if (amount != null && amount != "") {
    amount = double.parse(amount.toString());
    return NumberFormat.currency(symbol: '', decimalDigits: 0, locale: 'UZ').format(amount);
  } else {
    return NumberFormat.currency(symbol: '', decimalDigits: 0, locale: 'UZ').format(0);
  }
}

formatPhone(phone) {
  var y = phone.substring(3, 5);
  var z = phone.substring(5, 8);
  var d = phone.substring(8, 10);
  var q = phone.substring(10, 12);
  return y + ' ' + z + ' ' + d + ' ' + q;
}

showSuccessToast(message) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF28a745),
      textColor: Colors.white,
      fontSize: 16.0);
}
