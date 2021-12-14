const String pkgName = 'copy_with_extension_gen';

const String annotationsBase = r'''
class CopyWith {
  const CopyWith({
    this.copyWithValues = false,
    this.copyWithNull = false,
    this.copyWith = true,
    this.namedConstructor,
  });

  final bool copyWithValues;
  final bool copyWithNull;
  final bool copyWith;
  final String? namedConstructor;
}

class CopyWithField {
  const CopyWithField({this.immutable = false});

  final bool immutable;
}
''';

const String correctInput = r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'test_case_class.g.dart';

@CopyWith()
class Test_Case_Class<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;
  final List<T?> nullableGenerics;

  Test_Case_Class({
    required this.id, 
    required this.immutableField, 
    required this.nullableGenerics,
  });
}
''';

const String correctResult = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _Test_Case_ClassCopyWithProxy<T extends String> {
  final Test_Case_Class _value;

  _Test_Case_ClassCopyWithProxy(this._value);

  Test_Case_Class id(T id) => _value._copyWithValues(id: id);

  Test_Case_Class nullableGenerics(List<T?> nullableGenerics) =>
      _value._copyWithValues(nullableGenerics: nullableGenerics);
}

extension Test_Case_ClassCopyWith<T extends String> on Test_Case_Class<T> {
  _Test_Case_ClassCopyWithProxy get copyWith =>
      _Test_Case_ClassCopyWithProxy<T>(this);

  Test_Case_Class<T> _copyWithValues({
    T? id,
    List<T?>? nullableGenerics,
  }) {
    return Test_Case_Class<T>(
      id: id ?? this.id,
      immutableField: immutableField,
      nullableGenerics: nullableGenerics ?? this.nullableGenerics,
    );
  }
}
''';
