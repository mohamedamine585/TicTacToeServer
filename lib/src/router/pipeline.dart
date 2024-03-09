import 'dart:io';

class Pipeline {
  final HttpRequest _request;
  Pipeline(this._request);

  Pipeline addmiddleware(Function(HttpRequest) middleware) {
    middleware(_request);
    return this;
  }

  Future<void> addasynchandler(Function(HttpRequest) handler) async {
    await handler(_request);
  }

  void addhandler(Function(HttpRequest) handler) {
    handler(_request);
  }
}
