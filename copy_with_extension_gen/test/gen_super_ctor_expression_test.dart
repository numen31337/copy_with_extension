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

@CopyWith()
class MultiParamChild extends Base {
  MultiParamChild({required int b, required int c}) : super(a: (b + c) ~/ 2);
}

@CopyWith()
class BaseItem {
  const BaseItem({this.focusNodeCount = 0});

  final int focusNodeCount;
}

@CopyWith()
class FormItem extends BaseItem {
  FormItem({required this.quantities})
      : super(focusNodeCount: quantities.length);

  final List<String> quantities;
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

  test('copyWith handles multiple parameters in super initializer', () {
    final instance = MultiParamChild(b: 1, c: 3);
    final result = instance.copyWith(a: 5);
    expect(result, isA<MultiParamChild>());
    expect(result.a, 5);
  });

  test('copyWith handles local fields used in super initializer', () {
    final item = FormItem(quantities: ['a', 'b']);
    final copy = item.copyWith(quantities: ['x']);
    expect(copy.quantities, ['x']);
    expect(copy.focusNodeCount, 1);
  });
}
