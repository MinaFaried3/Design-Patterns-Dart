class ApiService {
  final bool hasInternet;
  final String? token;
  final bool hasPermission;

  const ApiService(
      {required this.hasInternet,
      required this.token,
      required this.hasPermission});
}

abstract class RequestHandler {
  RequestHandler? next;

  RequestHandler setNext(RequestHandler handler) {
    next = handler;
    return next!;
  }

  Future<void> handleRequest(ApiService apiService) async {
    if (next != null) {
      await next!.handleRequest(apiService);
    }
  }
}

class InternetCheckHandler extends RequestHandler {
  @override
  Future<void> handleRequest(ApiService apiService) async {
    if (!apiService.hasInternet) {
      print('has no internet');
      return;
    }
    return super.handleRequest(apiService);
  }
}

class AuthenticationHandler extends RequestHandler {
  @override
  Future<void> handleRequest(ApiService apiService) async {
    if (apiService.token == null || apiService.token!.isEmpty) {
      print('has no token');
      return;
    }
    return super.handleRequest(apiService);
  }
}

class PermissionHandler extends RequestHandler {
  @override
  Future<void> handleRequest(ApiService apiService) async {
    if (!apiService.hasPermission) {
      print('has no permission');
      return;
    }
    return super.handleRequest(apiService);
  }
}

class SuccessHandler extends RequestHandler {
  @override
  Future<void> handleRequest(ApiService apiService) async {
    print('API request executed successfully');
  }
}

void main() async {
  final apiService = ApiService(
    hasInternet: true,
    token: '123',
    hasPermission: true,
  );

  final internetCheckHandler = InternetCheckHandler();
  final authenticationHandler = AuthenticationHandler();
  final permissionHandler = PermissionHandler();
  final successHandler = SuccessHandler();

  internetCheckHandler
      .setNext(authenticationHandler)
      .setNext(permissionHandler)
      .setNext(successHandler);

  await internetCheckHandler.handleRequest(apiService);
}
