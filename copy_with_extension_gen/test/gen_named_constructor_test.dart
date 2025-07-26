import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_named_constructor_test.g.dart';

@CopyWith(constructor: "_")
class CopyWithNamedConstructor {
  const CopyWithNamedConstructor._({
    this.id,
  });

  final String? id;
}

@CopyWith(constructor: "first")
class CopyWithTwoThreeConstructors {
  const CopyWithTwoThreeConstructors({
    this.id,
  }) : field = "test";

  const CopyWithTwoThreeConstructors.first({
    this.id,
    required this.field,
  });

  const CopyWithTwoThreeConstructors.second({
    this.id,
    required this.field,
  });

  final String? id;
  final String field;
}

@CopyWith(constructor: "_")
class DefaultValuesConstructor {
  const DefaultValuesConstructor._({this.anotherField}) : field = "test";

  final String? id = "test";
  final String? field;
  final String? anotherField;
}

void main() {
  test('CopyWithNamedConstructor', () {
    expect(
      const CopyWithNamedConstructor._().copyWith.id("test").id,
      "test",
    );

    expect(
      const CopyWithNamedConstructor._(id: "test").copyWith.id(null).id,
      null,
    );
  });

  test('CopyWithTwoThreeConstructors', () {
    expect(
      const CopyWithTwoThreeConstructors().copyWith.id("test").id,
      "test",
    );

    expect(
      const CopyWithTwoThreeConstructors().copyWith.field("test123").field,
      "test123",
    );
  });

  test('DefaultValuesConstructor', () {
    final result = const DefaultValuesConstructor._(anotherField: "test")
        .copyWith
        .anotherField("123");

    expect(result.id, "test");
    expect(result.field, "test");
    expect(result.anotherField, "123");
  });
}
