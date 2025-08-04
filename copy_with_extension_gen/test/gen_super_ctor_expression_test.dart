import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_super_ctor_expression_test.g.dart';

@CopyWith()
class Base {
  const Base({required this.a});
  final int a;
}

@CopyWith()
class Derived extends Base {
  Derived({required int b}) : super(a: b.abs());
}

void main() {
  test('copyWith handles super initializer property access', () {
    final instance = Derived(b: 1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<Derived>());
    expect(result.a, 2);
  });
}
