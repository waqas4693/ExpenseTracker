import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    if (_authRepository.isLoggedIn()) {
      final storedUser = _authRepository.getStoredUser();
      if (storedUser != null) {
        currentUser.value = storedUser;
        isAuthenticated.value = true;
        // Optionally verify token with server
        try {
          final user = await _authRepository.getCurrentUser();
          currentUser.value = user;
          isAuthenticated.value = true;
        } catch (e) {
          // Token invalid, logout
          await signOut();
        }
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    isLoading.value = true;
    try {
      final authResponse = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );

      currentUser.value = authResponse.user;
      isAuthenticated.value = true;
      isLoading.value = false;

      Get.snackbar('Success', 'Account created successfully');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final authResponse = await _authRepository.signIn(
        email: email,
        password: password,
      );

      currentUser.value = authResponse.user;
      isAuthenticated.value = true;
      isLoading.value = false;

      Get.snackbar('Success', 'Signed in successfully');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authRepository.signOut();
      currentUser.value = null;
      isAuthenticated.value = false;
      isLoading.value = false;

      Get.offNamed(AppRoutes.signIn);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
}
