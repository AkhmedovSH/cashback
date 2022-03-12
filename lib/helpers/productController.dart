import 'package:get/get.dart';

class Controller extends GetxController {
  dynamic products = [].obs;
  addProduct(item) => {
        products.add(item),
        print(products),
        update(),
      };

  deleteProduct(index) => {products.removeAt(index).obs};
}
