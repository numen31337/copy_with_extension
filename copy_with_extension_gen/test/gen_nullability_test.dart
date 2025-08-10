import 'package:analyzer/dart/element/element2.dart' show FieldElement2;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/templates/copy_with_null_template.dart';
import 'package:copy_with_extension_gen/src/templates/copy_with_values_template.dart';
import 'package:test/test.dart';

part 'gen_nullability_test.g.dart';

@CopyWith()
class TestNullability {
  TestNullability(this.dynamicField, this.integers, {int? constructorFallback})
      : constructorFallback = constructorFallback ?? 0;

  /// https://github.com/numen31337/copy_with_extension/issues/74
  /// Test for crash on `instance.dynamicField!`.
  final dynamic dynamicField;

  /// https://github.com/numen31337/copy_with_extension/issues/75
  /// Warnings during compilation when using `!` on non-nullable value.
  /// Use `dart run copy_with_extension_gen/test/gen_nullability_test.dart` to reproduce the warning.
  final List<int> integers;

  /// https://github.com/numen31337/copy_with_extension/issues/79
  /// Case when a class has non-nullable type, but the constructor accepts nullable and falls back.
  final int constructorFallback;
}

@CopyWith(copyWithNull: true)
class PositionalNull {
  const PositionalNull(this.id, this.name);

  final int id;
  final String? name;
}

@CopyWith(copyWithNull: true)
class DynamicHolder {
  DynamicHolder(this.value);
  final dynamic value;
}

@CopyWith(copyWithNull: true)
class ParentNull {
  const ParentNull({this.a, this.b});

  final String? a;
  final int? b;
}

@CopyWith(copyWithNull: true)
class ChildNull extends ParentNull {
  const ChildNull({super.a, super.b, this.c, this.d});

  final double? c;
  final bool? d;
}

@CopyWith(skipFields: true)
class ChildNullSkip extends ParentNull {
  const ChildNullSkip({super.a, super.b, required this.c});

  final int c;
}

@CopyWith(copyWithNull: true)
class ParentNoNullable {
  const ParentNoNullable(this.a);

  final int a;
}

@CopyWith()
class ChildNoNullable extends ParentNoNullable {
  ChildNoNullable(super.a);
}

class _FakeConstructorParameterInfo implements ConstructorParameterInfo {
  _FakeConstructorParameterInfo({
    required this.name,
    required this.constructorParamName,
    required this.nullable,
    required bool immutable,
    this.isPositioned = false,
  })  : fieldAnnotation = CopyWithFieldAnnotation(immutable: immutable),
        type = 'int',
        classField = null,
        metadata = const [],
        isInherited = false;

  @override
  final String constructorParamName;
  @override
  final String name;
  @override
  final bool nullable;
  @override
  final String type;
  @override
  final CopyWithFieldAnnotation fieldAnnotation;
  @override
  final bool isPositioned;
  @override
  final FieldElement2? classField;
  @override
  final List<String> metadata;
  @override
  final bool isInherited;
  @override
  bool get classFieldNullable => true;
}

void main() {
  group('TestNullability dynamic field', () {
    test('unaffected when other field changes', () {
      expect(TestNullability(1, [1]).copyWith.integers([2]).dynamicField, 1);
    });

    test('updated via proxy method', () {
      expect(TestNullability(1, [1]).copyWith.dynamicField(2).dynamicField, 2);
    });

    test('updated via named parameter', () {
      expect(TestNullability(1, [1]).copyWith(dynamicField: 2).dynamicField, 2);
    });

    test('remains when integers updated', () {
      expect(TestNullability(1, [1]).copyWith(integers: [1]).dynamicField, 1);
    });

    test('null initial value updated', () {
      expect(
        TestNullability(null, [1]).copyWith.dynamicField(1).dynamicField,
        1,
      );
    });

    test('null initial value unaffected', () {
      expect(
        TestNullability(null, [1]).copyWith.integers([2]).dynamicField,
        null,
      );
    });

    group('constructor fallback', () {
      test('default value remains', () {
        expect(
          TestNullability(1, [1], constructorFallback: 1).constructorFallback,
          1,
        );
      });

      test('null resets to fallback', () {
        expect(
          TestNullability(
            1,
            [1],
            constructorFallback: 1,
          ).copyWith.constructorFallback(null).constructorFallback,
          0,
        );
      });

      test('value is updated', () {
        expect(
          TestNullability(
            1,
            [1],
            constructorFallback: 1,
          ).copyWith.constructorFallback(2).constructorFallback,
          2,
        );
      });
    });
  });

  test('copyWithNull works with positional nullable fields', () {
    const original = PositionalNull(1, 'name');
    final updated = original.copyWithNull(name: true);
    expect(updated, isA<PositionalNull>());
    expect(updated.id, 1);
    expect(updated.name, isNull);
  });

  test('explicit null for non-nullable field is ignored', () {
    final original = TestNullability(1, [1], constructorFallback: 1);
    final proxy = original.copyWith as dynamic;
    final result = proxy(integers: null) as TestNullability;
    expect(result.integers, [1]);
  });

  test('dynamic field null handling in copyWith and copyWithNull', () {
    final original = DynamicHolder('value');

    final viaCopyWith = original.copyWith(value: null);
    expect(viaCopyWith.value, isNull);

    final viaCopyWithNull = original.copyWithNull(value: true);
    expect(viaCopyWithNull.value, isNull);

    final unchanged = original.copyWithNull();
    expect(unchanged.value, 'value');
  });

  test('copyWithNull nullifies inherited and subclass fields', () {
    final child = ChildNull(a: 'a', b: 1, c: 2.0, d: true);

    final result = child.copyWithNull(a: true, d: true);
    expect(result, isA<ChildNull>());
    expect(result.a, isNull);
    expect(result.b, 1);
    expect(result.c, 2.0);
    expect(result.d, isNull);
  });

  test('copyWithNull nullifies inherited field and preserves child type', () {
    final child = ChildNullSkip(a: 'a', b: 1, c: 3);

    final dynamic result = child.copyWithNull(a: true);
    expect(result, isA<ChildNullSkip>());
    final childResult = result as ChildNullSkip;
    expect(childResult.a, isNull);
    expect(childResult.b, 1);
    expect(childResult.c, 3);
  });

  test('copyWithNull does not exist on the subclass without copyWithNull', () {
    final child = ChildNoNullable(1);
    final result = (child as dynamic);
    expect(() => result.copyWithNull(), throwsNoSuchMethodError);
  });

  test('copyWithNullTemplate keeps current value for non-nullable fields', () {
    final fields = [
      _FakeConstructorParameterInfo(
        name: 'a',
        constructorParamName: 'a',
        nullable: false,
        immutable: false,
      ),
      _FakeConstructorParameterInfo(
        name: 'b',
        constructorParamName: 'b',
        nullable: true,
        immutable: false,
      ),
    ];
    final result = copyWithNullTemplate('Test', fields, null, false);
    expect(result, contains('a,'));
    expect(result, contains('b == true ? null : this.b'));
  });

  test('copyWithValuesTemplate handles immutable positioned fields', () {
    final field = _FakeConstructorParameterInfo(
      name: 'a',
      constructorParamName: 'a',
      nullable: false,
      immutable: true,
      isPositioned: true,
    );
    final result = copyWithValuesTemplate(
      'Test',
      [field],
      [field],
      null,
      false,
      false,
    );
    expect(result, contains('_value.a,'));
  });
}
