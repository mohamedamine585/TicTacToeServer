import 'dart:convert';
import 'dart:io';

Function(HttpRequest) checkbodyForPlayerupdate = (HttpRequest request) async {
  try {
    var body = json.decode(await utf8.decodeStream(request));
    if (body["email"] != null ||
        body["name"] != null ||
        body["lastconnection"] != null) {
      // change constraint  ********************

      if (body["email"].length != 0 || body["name"].length != 0) {
        request.response.headers.set("name", body["name"]);
        request.response.headers.set("email", body["email"]);
      }
    }
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write(json.encode({"message": "Invalid Body"}));
  } catch (e) {
    print(e);
  }
  return null;
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
