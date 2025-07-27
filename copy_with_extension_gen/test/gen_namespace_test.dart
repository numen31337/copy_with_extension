import 'dart:typed_data' as ns;
import 'dart:typed_data' as ns1;
import 'dart:async' as ns2;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_namespace_test.g.dart';

class Uint16List {
  const Uint16List();
}

@CopyWith()
class NamespaceTestClass {
  const NamespaceTestClass({
    this.namespacedProperty,
    this.namespacedProperty1,
    this.namespacedProperty2,
    this.regularProperty = const Uint16List(),
    this.stringProperty,
    this.boolProperty,
  });

  final ns.Uint16List? namespacedProperty;
  final ns1.Uint16List? namespacedProperty1;
  final ns2.Future<ns1.Uint16List>? namespacedProperty2;
  final Uint16List regularProperty;
  final String? stringProperty;
  final bool? boolProperty;
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
