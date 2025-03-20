import 'package:http/http.dart' as http;

class NoRedirectsClient extends http.BaseClient {
  final http.Client _inner;

  NoRedirectsClient([http.Client? client]) : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.followRedirects = false;
    return _inner.send(request);
  }
}