const { spawnSync } = require('child_process');

// Replace 'hello.dart' with the actual name of your Dart file
const dartFilePath = 'lib/main.dart';

// Run Dart file using spawnSync
const result = spawnSync('dart', [dartFilePath]);

// Print Dart process output
console.log('Dart stdout:', result.stdout.toString());

// Print Dart process errors, if any
if (result.stderr && result.stderr.length > 0) {
  console.error('Dart stderr:', result.stderr.toString());
}

// Print Dart process exit code
console.log('Dart process exited with code', result.status);
