import 'package:get/get.dart';
import '../model/character.dart';
import '../service/api_service.dart';

class DetailController extends GetxController {
  final ApiService _api = ApiService();

  // Karakter yang dipilih di Home (dikirim lewat Get.arguments)
  final Character selected = Get.arguments as Character;

  final Rxn<Character> character = Rxn<Character>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  /// GET /character/{id}
  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      character.value = await _api.fetchCharacter(selected.id);
    } catch (e) {
      errorMessage.value =
          e is ApiException ? e.message : 'Terjadi kesalahan tak terduga.';
    } finally {
      isLoading.value = false;
    }
  }
}
