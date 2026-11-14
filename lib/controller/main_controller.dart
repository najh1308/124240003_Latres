import 'package:get/get.dart';

/// Mengatur tab aktif pada Bottom Navigation Bar.
class MainController extends GetxController {
  final RxInt index = 0.obs;

  void changeTab(int i) => index.value = i;
}
