import 'dart:io';

class Pipeline {
  final HttpRequest _request;
  Pipeline(this._request);

  Pipeline addMiddleware(Function(HttpRequest) middleware) {
    middleware(_request);
    return this;
  }

  Future<Pipeline> addAsyncMiddleware(Function(HttpRequest) middleware) async {
    await middleware(_request);
    return this;
  }

  Future<void> addAsyncHandler(Function(HttpRequest) handler) async {
    await handler(_request);
  }

  Future<void> close(HttpRequest request) async {
    await request.response.close();
  }

  void addHandler(Function(HttpRequest) handler) {
    handler(_request);
  }
}
