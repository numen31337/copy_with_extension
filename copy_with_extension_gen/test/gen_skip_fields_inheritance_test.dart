import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

import 'helpers/golden_test_utils.dart';

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

@CopyWith()
class Grandparent {
  const Grandparent({required this.a});

  final int a;
}

@CopyWith(skipFields: true)
class ParentSkip extends Grandparent {
  const ParentSkip({required super.a, required this.b});

  final int b;
}

@CopyWith(skipFields: true)
class ChildSkip extends ParentSkip {
  const ChildSkip({required super.a, required super.b, required this.c});

  final int c;
}

void main() {
  group('skipFields with inheritance', () {
    test(
      'child proxy is generated independently when superclass skips fields',
      () async {
        await expectGeneratedCodeMatchesGolden(
          sourceDirectory: 'test',
          sourceFile: 'gen_skip_fields_inheritance_test.dart',
          elementName: 'Child',
          goldenFilePath:
              'test/goldens/gen_skip_fields_inheritance__child_proxy_when_parent_skips_fields.golden',
        );
      },
    );

    test('Skip-field inheritance through unannotated intermediate', () {
      const c = C(1, 2, 3);

      final copy = c.copyWith(a: 4);
      expect(copy, isA<C>());
      expect(copy.a, 4);

      final dynamic proxy = c.copyWith;
      expect(() => proxy.a(5), throwsNoSuchMethodError);
    });

    test('skipFields suppresses ancestor field methods on the child proxy', () {
      const child = ChildSkip(a: 1, b: 2, c: 3);

      final viaCall = child.copyWith(a: 4);
      expect(viaCall, isA<ChildSkip>());
      expect(viaCall.a, 4);

      final dynamic proxy = child.copyWith;
      expect(() => proxy.a(5), throwsNoSuchMethodError);
    });
  });
}
