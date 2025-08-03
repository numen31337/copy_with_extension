import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_skip_fields_inheritance_test.g.dart';

@CopyWith(skipFields: true)
class Parent {
  const Parent({required this.a});

  final int a;
}

@CopyWith()
class Child extends Parent {
  const Child({required super.a, required this.b});

  final int b;
}

void main() {
  test('inherited field methods omit @override when superclass skips fields',
      () async {
    final content = await File('test/gen_skip_fields_inheritance_test.g.dart')
        .readAsString();
    expect(content, contains('Child a(int a)'));
    expect(content, isNot(contains('@override\n  Child a(int a);')));
  });
}
