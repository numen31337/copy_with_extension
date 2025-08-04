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

@CopyWith()
class PosBase {
  const PosBase(this.a);
  final int a;
}

@CopyWith()
class BinaryChild extends PosBase {
  BinaryChild(int a) : super(a + 0);
}

int identity(int value) => value;

@CopyWith()
class FunctionChild extends PosBase {
  FunctionChild(int a) : super(identity(a));
}

@CopyWith()
class RenamedParamChild extends Base {
  RenamedParamChild({required int b}) : super(a: b + 0);
}

@CopyWith()
class RenamedFunctionChild extends Base {
  RenamedFunctionChild({required int b}) : super(a: identity(b));
}

void main() {
  test('copyWith handles super initializer property access', () {
    final instance = Derived(b: 1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<Derived>());
    expect(result.a, 2);
  });

  test('copyWith handles binary expressions in super initializer', () {
    final instance = BinaryChild(1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<BinaryChild>());
    expect(result.a, 2);
  });

  test('copyWith handles function arguments in super initializer', () {
    final instance = FunctionChild(1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<FunctionChild>());
    expect(result.a, 2);
  });

  test('copyWith handles expressions with renamed parameters', () {
    final instance = RenamedParamChild(b: 1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<RenamedParamChild>());
    expect(result.a, 2);
  });

  test('copyWith handles function arguments with renamed parameters', () {
    final instance = RenamedFunctionChild(b: 1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<RenamedFunctionChild>());
    expect(result.a, 2);
  });
}
