import 'package:web_socket_channel/io.dart';

void main(List<String> args) {
  try {
    final channel = IOWebSocketChannel.connect('ws://127.0.0.1:8080', headers: {
      "token":
          "fbAaRSvyGadSMMzsKxEqkgGxuKDeNen6dr8cWoHLWA4 iJJWGebaQIsKOa8dXpcqCZwzonnhZwYG.PD0X8Gpwv."
    });
    channel.stream.listen((message) {
      print('Received: $message');
    });
  } catch (e) {
    print(e);
  }
}
