import 'package:get/get.dart';

class Controller extends GetxController {
  dynamic products = [].obs;
  addProduct(item) => {
        products = item,
        update(),
      };

  deleteProduct(index) => {products.removeAt(index).obs};
}
