import 'dart:convert';
import 'dart:io';

Function(HttpRequest) checkbodyForPlayerupdate = (HttpRequest request) async {
  var body = json.decode(await utf8.decodeStream(request));
  if (body["email"] != null ||
      body["name"] != null ||
      body["lastconnection"] != null) {
    // change constraint  ********************

    if (body["email"] != null && body["email"].length != 0) {
      request.response.headers.set("email", body["email"]);
    }
    if (body["name"] != null && body["name"].length != 0) {
      request.response.headers.set("name", body["name"]);
    }
  } else {
    request.response.statusCode = HttpStatus.badRequest;
    throw Exception("Invalid body");
  }
};

bool check_signinRequest({required HttpRequest request}) {
  try {
    return request.uri.queryParameters["playername"] != null &&
        request.uri.queryParameters["password"] != null;
  } catch (e) {
    print("Cannot check sign in params");
  }
  return false;
}
