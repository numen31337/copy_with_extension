import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_basic_class_test_.g.dart';

@CopyWith()
class BasicClass {
  final String id;
  final String? optional;
  @CopyWithField(immutable: true)
  final int immutable;
  @CopyWithField(immutable: true)
  final int nullableImmutable;

  const BasicClass({
    required this.id,
    this.optional,
    required this.immutable,
    required this.nullableImmutable,
  });
}

void main() {
  test('BasicClass test', () {
    const basicClass = BasicClass(
      id: '',
      immutable: 0,
      nullableImmutable: 0,
    );

    expect(basicClass.copyWith.id("test").id, "test");
  });
}
