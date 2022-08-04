import 'dart:ffi';
import 'dart:typed_data' as td;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_namespace_test.g.dart';

class ByteBuffer {}

@CopyWith()
class NamespaceTestClass {
  final td.ByteBuffer? namespacedProperty;
  final ByteBuffer? regularProperty;
  final String? stringProperty;
  final bool? boolProperty;

  const NamespaceTestClass({
    this.namespacedProperty,
    this.regularProperty,
    this.stringProperty,
    this.boolProperty,
  });
}

void main() {
  // TODO: do some basic tests to compare types
  test('Namespace', () {
    expect(
      const NamespaceTestClass().stringProperty,
      null,
    );
  });
}
