import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_moment/simple_moment.dart';

// Colors

Color purple = const Color(0xFF7D4196);
Color white = const Color(0xFFFFFFFF);
Color red = const Color(0xFFdc3545);
Color blue = const Color(0xFF17a2b8);
Color grey = const Color(0xFF838488);
Color lightGrey = const Color(0xFF9C9C9C);
Color borderColor = const Color(0xFFF8F8F8);

// Date formaters

formatDate(date) {
  // return DateFormat('dd.MM.yyyy HH:mm').format(date);
  Moment rawDate = Moment.parse(date);
  return rawDate.format("dd-MM-yyyy HH:mm");
}

formatMoney(amount) {
  if (amount != null && amount != "") {
    amount = double.parse(amount.toString());
    return NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'UZ').format(amount);
  } else {
    return NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'UZ').format(0);
  }
}
