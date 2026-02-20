import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';

import 'field_utils.dart';

/// Generates the `copyWithNull` method.
String copyWithNullTemplate(
  String typeAnnotation,
  List<ConstructorParameterInfo> fields,
  String? constructor,
  bool skipFields,
) {
  final uniqueFields = uniqueConstructorFields(fields);
  final nullableMutableFields = uniqueFields
      .where(
          (element) => element.nullable && !element.fieldAnnotation.immutable)
      .toList();
  // Return an empty string when the class has no nullable mutable fields.
  if (nullableMutableFields.isEmpty) {
    return '';
  }

  // Build the constructor parameter list. Only nullable and mutable fields need a boolean flag to specify nullification.
  final nullConstructorInput = nullableMutableFields.fold<String>('', (r, v) {
    final annotations = v.metadata.isEmpty ? '' : '${v.metadata.join(' ')} ';
    return '$r ${annotations}bool ${v.name} = false,';
  });

  // Build the actual invocation parameters for the constructor call.
  final nullParamsInput = fields.fold<String>('', (r, v) {
    final prefix = v.isPositioned ? '' : '${v.constructorParamName}:';
    if (v.fieldAnnotation.immutable || !v.nullable) {
      return '$r $prefix ${v.name},';
    } else {
      return '$r $prefix ${v.name} == true ? null : this.${v.name},';
    }
  });

  final description = '''
    /// Returns a copy of the object with the selected fields set to `null`.
    /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)`${skipFields ? '' : ' or `copyWith.fieldName(null)` for single-field updates'}.
    ///
    /// Example:
    /// ```dart
    /// $typeAnnotation(...).copyWithNull(firstField: true, secondField: true)
    /// ```''';

  return '''
      $description
      $typeAnnotation copyWithNull({$nullConstructorInput}) {
        return ${ConstructorUtils.constructorFor(typeAnnotation, constructor)}($nullParamsInput);
      }
     ''';
}
