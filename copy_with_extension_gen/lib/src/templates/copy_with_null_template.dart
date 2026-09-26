import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

/// Generates the `copyWithNull` method.
String copyWithNullTemplate(ResolvedCopyWithSpec spec) {
  final nullableMutableFields = spec.uniqueNullableMutableFields;
  // Return an empty string when the class has no nullable mutable fields.
  if (nullableMutableFields.isEmpty) {
    return '';
  }

  // Build the constructor parameter list. Only nullable and mutable fields
  // need a boolean flag to specify nullification.
  final nullConstructorInput = nullableMutableFields
      .map(
        (field) =>
            '${field.annotationPrefix}${spec.clearFlagType} ${field.name} = false,',
      )
      .join(' ');

  // Build the actual invocation parameters for the constructor call.
  final nullParamsInput = spec.constructorFields
      .map((field) => _constructorArg(field, isRecord: spec.isRecord))
      .join(' ');

  final description = '''
    /// Returns a copy of the object with the selected fields set to `null`.
    /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)`${spec.skipFields ? '' : ' or `copyWith.fieldName(null)` for single-field updates'}.
    ///
    /// Example:
    /// ```dart
    /// ${spec.exampleReceiver}.copyWithNull(firstField: true, secondField: true)
    /// ```''';

  return '''
      $description
      ${spec.typeAnnotation} copyWithNull({$nullConstructorInput}) {
        return ${spec.reconstruct(nullParamsInput)};
      }
     ''';
}

String _constructorArg(ResolvedCopyWithField field, {required bool isRecord}) {
  if (!field.supportsCopyWithNull) {
    return '${field.constructorArgPrefix}${isRecord ? 'this.' : ''}${field.name},';
  }
  return '${field.constructorArgPrefix}${field.name} == true ? null : this.${field.name},';
}
