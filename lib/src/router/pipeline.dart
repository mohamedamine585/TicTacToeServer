import 'dart:io';

class Pipeline {
  final HttpRequest _request;
  Pipeline(this._request);

  Pipeline addmiddleware(Function(HttpRequest) middleware) {
    middleware(_request);
    return this;
  }

  Future<Pipeline> addasyncmiddleware(Function(HttpRequest) middleware) async {
    await middleware(_request);
    return this;
  }

  Future<void> addasynchandler(Function(HttpRequest) handler) async {
    await handler(_request);
  }

  Future<void> close(HttpRequest request) async {
    await request.response.close();
  }

  void addhandler(Function(HttpRequest) handler) {
    handler(_request);
  }
}
