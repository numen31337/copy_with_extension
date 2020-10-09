const String pkgName = 'copy_with_extension_gen';

const String annotationsBase = r'''
class CopyWith {
  const CopyWith({this.generateCopyWithNull = false})
      : assert(generateCopyWithNull is bool);

  final bool generateCopyWithNull;
}

class CopyWithField {
  const CopyWithField({this.immutable = false}) : assert(immutable is bool);
  
  final bool immutable;
}
''';

const String correctInput = r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'test_case_class.g.dart';

@CopyWith(generateCopyWithNull: true)
class Test_Case_Class<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;

  Test_Case_Class({this.id, this.immutableField});
}
''';

const String correctResult = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension Test_Case_ClassCopyWithExtension<T extends String>
    on Test_Case_Class<T> {
  Test_Case_Class<T> copyWith({
    T id,
  }) {
    return Test_Case_Class<T>(
      id: id ?? this.id,
      immutableField: immutableField,
    );
  }

  Test_Case_Class<T> copyWithNull({
    bool id = false,
  }) {
    return Test_Case_Class<T>(
      id: id == true ? null : this.id,
      immutableField: immutableField,
    );
  }
}
''';
