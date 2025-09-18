import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_allow_null_for_non_nullable_fields_test.g.dart';

// Test default behavior (backward compatibility)
@CopyWith()
class DefaultClass {
  const DefaultClass({required this.id, required this.name, this.email});

  final int id;
  final String name;
  final String? email;
}

// Test with flag enabled via annotation
@CopyWith(allowNullForNonNullableFields: true)
class OptionalFieldsClass {
  const OptionalFieldsClass({required this.id, required this.name, this.email});

  final int id;
  final String name;
  final String? email;
}

// Test with generics
@CopyWith(allowNullForNonNullableFields: true)
class GenericClass<T> {
  const GenericClass({required this.id, required this.value});

  final int id;
  final T value;
}

void main() {
  group('Default behavior (backward compatibility)', () {
    test('requires non-nullable fields', () {
      final instance =
          DefaultClass(id: 1, name: 'test', email: 'test@test.com');

      // Should compile and work
      instance.copyWith(id: 2);
      instance.copyWith(name: 'new');
      instance.copyWith(email: null);

      // Should not compile:
      // instance.copyWith(); // Error: missing required parameters
    });
  });

  group('With allowNullForNonNullableFields enabled', () {
    test('makes non-nullable fields optional', () {
      final instance =
          OptionalFieldsClass(id: 1, name: 'test', email: 'test@test.com');

      // Should allow updating single fields without providing others
      final result1 = instance.copyWith(id: 2);
      expect(result1.id, 2);
      expect(result1.name, 'test');
      expect(result1.email, 'test@test.com');

      final result2 = instance.copyWith(name: 'new');
      expect(result2.id, 1);
      expect(result2.name, 'new');
      expect(result2.email, 'test@test.com');

      // Should still allow updating multiple fields
      final result3 = instance.copyWith(id: 3, name: 'both');
      expect(result3.id, 3);
      expect(result3.name, 'both');
      expect(result3.email, 'test@test.com');

      // Should allow empty copyWith
      final result4 = instance.copyWith();
      expect(result4.id, 1);
      expect(result4.name, 'test');
      expect(result4.email, 'test@test.com');
    });

    test('still respects field nullability', () {
      final instance =
          OptionalFieldsClass(id: 1, name: 'test', email: 'test@test.com');

      // Should not allow null for non-nullable fields
      // These should not compile:
      // instance.copyWith(id: null);
      // instance.copyWith(name: null);

      // Should allow null for nullable fields
      final result = instance.copyWith(email: null);
      expect(result.email, null);
    });
  });

  group('With generics', () {
    test('handles non-nullable generic types', () {
      final instance = GenericClass<String>(id: 1, value: 'test');

      // Should allow updating just id
      final result1 = instance.copyWith(id: 2);
      expect(result1.id, 2);
      expect(result1.value, 'test');

      // Should allow updating just value
      final result2 = instance.copyWith(value: 'new');
      expect(result2.id, 1);
      expect(result2.value, 'new');

      // Should not allow null for non-nullable generic
      // This should not compile:
      // instance.copyWith(value: null);
    });
  });
}
