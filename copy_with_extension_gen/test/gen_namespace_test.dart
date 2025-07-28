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
  test('Namespace copyWith retains types', () {
    final result = const NamespaceTestClass().copyWith(
      namespacedProperty: ns.Uint16List(0),
      namespacedProperty1: ns1.Uint16List(0),
      namespacedProperty2: ns2.Future<ns1.Uint16List>.value(ns1.Uint16List(0)),
      regularProperty: const Uint16List(),
      stringProperty: 'foo',
      boolProperty: true,
    );

    expect(result.namespacedProperty, isA<ns.Uint16List>());
    expect(result.namespacedProperty1, isA<ns1.Uint16List>());
    expect(result.namespacedProperty2, isA<ns2.Future<ns1.Uint16List>>());
    expect(result.regularProperty, isA<Uint16List>());
    expect(result.stringProperty, 'foo');
    expect(result.boolProperty, true);
  });

  test('Field specific copyWith methods work', () {
    final original = const NamespaceTestClass();

    final withNamespaced =
        original.copyWith.namespacedProperty(ns.Uint16List(0));
    expect(withNamespaced.namespacedProperty, isA<ns.Uint16List>());

    final withNamespaced1 =
        original.copyWith.namespacedProperty1(ns1.Uint16List(0));
    expect(withNamespaced1.namespacedProperty1, isA<ns1.Uint16List>());

    final future = ns2.Future<ns1.Uint16List>.value(ns1.Uint16List(0));
    final withNamespaced2 = original.copyWith.namespacedProperty2(future);
    expect(
        withNamespaced2.namespacedProperty2, isA<ns2.Future<ns1.Uint16List>>());

    final withRegular = original.copyWith.regularProperty(const Uint16List());
    expect(withRegular.regularProperty, isA<Uint16List>());
  });
}
