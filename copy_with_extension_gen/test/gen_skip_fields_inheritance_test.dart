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

@CopyWith()
class A {
  const A(this.a);

  final int a;
}

class B extends A {
  const B(super.a, this.b);

  final int b;
}

@CopyWith(skipFields: true)
class C extends B {
  const C(super.a, super.b, this.c);

  final int c;
}

void main() {
  test('inherited field methods omit @override when superclass skips fields',
      () async {
    final content = await File('test/gen_skip_fields_inheritance_test.g.dart')
        .readAsString();
    expect(content, contains('Child a(int a)'));
    expect(content, isNot(contains('@override\n  Child a(int a);')));
  });

  test('Skip-field inheritance through unannotated intermediate', () {
    const c = C(1, 2, 3);

    final copy = c.copyWith(a: 4);
    expect(copy, isA<C>());
    expect(copy.a, 4);

    final dynamic proxy = c.copyWith;
    expect(() => proxy.a(5), throwsNoSuchMethodError);
  });
}
