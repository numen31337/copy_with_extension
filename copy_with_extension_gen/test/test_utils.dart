import 'dart:io';

/// Reads the generated output for a test file.
Future<String> readGeneratedFile(String fileName) {
  return File('test/$fileName').readAsString();
}
