
import 'package:get/get.dart';

import '../locales/en.dart';
import '../locales/ru.dart';
import '../locales/uz_cyrl.dart';
import '../locales/uz_latn.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'ru_RU': ru,
        'uz_cyrl_UZ': uz_cyrl,
        'uz_latn_UZ': uz_latn,
      };
}
