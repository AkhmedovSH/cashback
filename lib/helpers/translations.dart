import 'package:get/get.dart';

import '../locales/ru.dart';
import '../locales/uz_cyrl.dart';
import '../locales/uz_latn.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ru': ru,
        'uz-Cyrl-UZ': uzCyrl,
        'uz-Latn-UZ': uzLatn,
      };
}
