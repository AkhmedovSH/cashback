import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashback/helpers/api.dart';
import 'package:cashback/helpers/helper.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, right: 16, left: 16),
              height: 40,
              child: TextField(
                onChanged: (value) {},
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(2),
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: grey,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  hintText: 'Поиск по названию, QR code ...',
                  hintStyle: TextStyle(
                    color: lightGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
