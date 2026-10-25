/*
Violates Open/Closed Principle (OCP): Adding another validation requires modifying executeRequest.

Violates Single Responsibility Principle (SRP): The service handles internet checks, authentication, authorization, and execution.

Difficult to reuse: Cannot easily reuse individual validation handlers.

Hard to test: Validation rules are coupled together.
 */

class ApiService {
  Future<void> executeRequest({
    required bool hasInternet,
    required String? token,
    required bool hasPermission,
  }) async {
    if (!hasInternet) {
      print('No internet connection');
      return;
    }

    if (token == null || token.isEmpty) {
      print('User is not authenticated');
      return;
    }

    if (!hasPermission) {
      print('Permission denied');
      return;
    }

    print('API request executed successfully');
  }
}
