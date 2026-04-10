import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

/// Generates the `copyWithNull` method.
String copyWithNullTemplate(ResolvedCopyWithSpec spec) {
  final nullableMutableFields = spec.uniqueNullableMutableFields;
  // Return an empty string when the class has no nullable mutable fields.
  if (nullableMutableFields.isEmpty) {
    return '';
  }

  // Build the constructor parameter list. Only nullable and mutable fields need a boolean flag to specify nullification.
  final nullConstructorInput = nullableMutableFields.fold<String>('', (
    r,
    field,
  ) {
    final annotations =
        field.metadata.isEmpty ? '' : '${field.metadata.join(' ')} ';
    return '$r ${annotations}bool ${field.name} = false,';
  });

  // Build the actual invocation parameters for the constructor call.
  final nullParamsInput = spec.constructorFields.fold<String>('', (r, field) {
    final prefix = field.isPositioned ? '' : '${field.constructorParamName}:';
    if (!field.supportsCopyWithNull) {
      return '$r $prefix ${field.name},';
    } else {
      return '$r $prefix ${field.name} == true ? null : this.${field.name},';
    }
  });

  final description = '''
    /// Returns a copy of the object with the selected fields set to `null`.
    /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)`${spec.skipFields ? '' : ' or `copyWith.fieldName(null)` for single-field updates'}.
    ///
    /// Example:
    /// ```dart
    /// ${spec.typeAnnotation}(...).copyWithNull(firstField: true, secondField: true)
    /// ```''';

  return '''
      $description
      ${spec.typeAnnotation} copyWithNull({$nullConstructorInput}) {
        return ${ConstructorUtils.constructorFor(spec.typeAnnotation, spec.constructorName)}($nullParamsInput);
      }
     ''';
}
