import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Colors

Color purple = const Color(0xFF7D4196);

// Date formaters

formatDate(date) {
  return DateFormat('dd.MM.yyyy HH:mm').format(date);
  // Moment rawDate = Moment.parse(date);
  // return rawDate.format("dd.MM.yyyy HH:mm");
}
