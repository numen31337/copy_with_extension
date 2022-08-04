import 'dart:typed_data' as ns;
import 'dart:typed_data' as ns1;
import 'dart:async' as ns2;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_namespace_test.g.dart';

class ByteBuffer {
  const ByteBuffer();
}

@CopyWith()
class NamespaceTestClass {
  final ns.ByteBuffer? namespacedProperty;
  final ns1.ByteBuffer? namespacedProperty1;
  final ns2.Future<ns1.ByteBuffer>? namespacedProperty2;
  final ByteBuffer regularProperty;
  final String? stringProperty;
  final bool? boolProperty;

  const NamespaceTestClass({
    this.namespacedProperty,
    this.namespacedProperty1,
    this.namespacedProperty2,
    this.regularProperty = const ByteBuffer(),
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
