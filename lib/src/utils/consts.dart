import 'dart:io';

const PORT_GAME = 8080;

const PORT_AUTH = 8081;

const HOST_GAME = '0.0.0.0';
const HOST_AUTH = '0.0.0.0';
const SECRET_SAUCE = "7@SecretTliliSauce@7";
final context = SecurityContext.defaultContext
  ..useCertificateChain(
      'C:/Users/foxwe/OneDrive/Bureau/tic_tac_toe_server/public-cert.pem') // Replace with your certificate file
  ..usePrivateKey(
      'C:/Users/foxwe/OneDrive/Bureau/tic_tac_toe_server/private-key.pem'); // Replace with your private key file

const IMG_QUALITY = 30;
