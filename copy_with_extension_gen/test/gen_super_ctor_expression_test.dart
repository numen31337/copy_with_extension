import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_super_ctor_expression_test.g.dart';

@CopyWith()
class Base {
  const Base({required this.a});
  final int a;
}

@CopyWith()
class RenamedDirectChild extends Base {
  RenamedDirectChild({required int b}) : super(a: b);
}

@CopyWith()
class PosBase {
  const PosBase(this.a);
  final int a;
}

@CopyWith()
class PositionalDirectChild extends PosBase {
  PositionalDirectChild(super.a);
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
  test('copyWith handles direct renamed super initializer', () {
    final instance = RenamedDirectChild(b: 1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<RenamedDirectChild>());
    expect(result.a, 2);
  });

  test('copyWith handles direct positional super initializer', () {
    final instance = PositionalDirectChild(1);
    final result = instance.copyWith(a: 2);
    expect(result, isA<PositionalDirectChild>());
    expect(result.a, 2);
  });

  test('copyWith handles local fields used in super initializer', () {
    final item = FormItem(quantities: ['a', 'b']);
    final copy = item.copyWith(quantities: ['x']);
    expect(copy.quantities, ['x']);
    expect(copy.focusNodeCount, 1);
  });
}
