import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_named_constructor_test.g.dart';

@CopyWith(constructor: "_")
class CopyWithNamedConstructor {
  const CopyWithNamedConstructor._({this.id});

  final String? id;
}

@CopyWith(constructor: "first")
class CopyWithTwoThreeConstructors {
  const CopyWithTwoThreeConstructors({this.id}) : field = "test";

  const CopyWithTwoThreeConstructors.first({this.id, required this.field});

  const CopyWithTwoThreeConstructors.second({this.id, required this.field});

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

@CopyWith(constructor: 'named')
class SuperNamed {
  const SuperNamed.named({required this.a});

  final int a;
}

@CopyWith()
class SubNamed extends SuperNamed {
  const SubNamed({required super.a, required this.b}) : super.named();

  final String b;
}

@CopyWith(constructor: 'other')
class SubNamedOther extends SuperNamed {
  const SubNamedOther.other({required super.a, required this.b})
      : super.named();

  final String b;
}

@CopyWith()
class RedirectingNoParams {
  RedirectingNoParams() : this._(0);
  RedirectingNoParams._(this.value);

  final int value;
}

@CopyWith()
class RedirectingMultiLevel {
  RedirectingMultiLevel() : this._first();
  RedirectingMultiLevel._first() : this._second(0);
  RedirectingMultiLevel._second(this.value);

  final int value;
}

@CopyWith()
class FactoryRedirectMultiLevel {
  factory FactoryRedirectMultiLevel(int value) =
      FactoryRedirectMultiLevel._first;
  factory FactoryRedirectMultiLevel._first(int value) =
      FactoryRedirectMultiLevel._second;
  FactoryRedirectMultiLevel._second(this.value);

  final int value;
}

void main() {
  test('CopyWithNamedConstructor', () {
    expect(const CopyWithNamedConstructor._().copyWith.id("test").id, "test");

    expect(
      const CopyWithNamedConstructor._(id: "test").copyWith.id(null).id,
      null,
    );
  });

  test('CopyWithTwoThreeConstructors', () {
    expect(const CopyWithTwoThreeConstructors().copyWith.id("test").id, "test");

    expect(
      const CopyWithTwoThreeConstructors().copyWith.field("test123").field,
      "test123",
    );
  });

  test('DefaultValuesConstructor', () {
    final result = const DefaultValuesConstructor._(
      anotherField: "test",
    ).copyWith.anotherField("123");

    expect(result.id, "test");
    expect(result.field, "test");
    expect(result.anotherField, "123");
  });

  test('Subclass proxy respects superclass named constructor', () {
    final original = SubNamed(a: 1, b: 'b');

    final updated = original.copyWith(a: 2, b: 'c');
    expect(updated, isA<SubNamed>());
    expect(updated.a, 2);
    expect(updated.b, 'c');

    final baseUpdated = original.copyWith(a: 3);
    expect(baseUpdated, isA<SubNamed>());
    expect(baseUpdated.a, 3);
    expect(baseUpdated.b, 'b');
  });

  test('Subclass with its own named constructor uses correct constructors', () {
    final original = SubNamedOther.other(a: 1, b: 'b');

    final updated = original.copyWith(a: 2, b: 'c');
    expect(updated, isA<SubNamedOther>());
    expect(updated.a, 2);
    expect(updated.b, 'c');

    final baseUpdated = original.copyWith(a: 3);
    expect(baseUpdated, isA<SubNamedOther>());
    expect(baseUpdated.a, 3);
    expect(baseUpdated.b, 'b');
  });

  test('copyWith works with redirecting constructor without parameters', () {
    final original = RedirectingNoParams();
    final updated = original.copyWith(value: 42);
    expect(updated.value, 42);
  });

  test('copyWith follows multi-level redirecting constructors', () {
    final original = RedirectingMultiLevel();
    final updated = original.copyWith(value: 24);
    expect(updated.value, 24);
  });

  test('copyWith follows multi-level factory redirects', () {
    final original = FactoryRedirectMultiLevel(0);
    final updated = original.copyWith(value: 10);
    expect(updated.value, 10);
  });
}
