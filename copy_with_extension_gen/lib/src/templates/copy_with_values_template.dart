import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

/// Generates the body of the `call` method used by the proxy.
/// The returned snippet can be used either as an abstract interface (when [isAbstract] is `true`)
/// or as a concrete implementation that instantiates the target class.
String copyWithValuesTemplate(
  ResolvedCopyWithSpec spec, {
  required bool isAbstract,
  bool addOverride = false,
}) {
  // Build the parameter list for the generated function or abstract interface.
  // Immutable fields are excluded entirely.
  final constructorInput = spec.uniqueMutableFields
      .map((field) => _callParameter(field, isAbstract: isAbstract))
      .join('\n    ');

  // Generate the parameters passed to the constructor when creating the new
  // instance. Immutable fields are copied from the existing value.
  final paramsInput = spec.constructorFields
      .map((field) => _constructorArg(field))
      .join(' ');

  final constructorBody =
      isAbstract
          ? ''
          : '{ return ${spec.constructorReference}($paramsInput); }';
  final callParameters =
      constructorInput.trim().isEmpty ? '' : '{$constructorInput}';

  return '''
        /// Creates a new instance with the provided field values.
        /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.${spec.skipFields ? '' : ' To update a single field use `${spec.typeAnnotation}(...).copyWith.fieldName(value)`.'}
        ///
        /// Example:
        /// ```dart
        /// ${spec.typeAnnotation}(...).copyWith(id: 12, name: "My name")
        /// ```
${addOverride ? '        @override\n' : ''}        ${spec.typeAnnotation} call($callParameters) $constructorBody
    ''';
}

/// Builds a single parameter for the `call` method signature.
String _callParameter(ResolvedCopyWithField field, {required bool isAbstract}) {
  if (isAbstract) {
    // When generating the interface, parameters are typed directly.
    return '${field.annotationPrefix}${field.type} ${field.name},';
  }
  // The implementation uses [$CopyWithPlaceholder] to detect whether a
  // parameter was passed.
  return '${field.annotationPrefix}Object? ${field.name} = const \$CopyWithPlaceholder(),';
}

/// Builds a single argument for the constructor invocation inside `call`.
String _constructorArg(ResolvedCopyWithField field) {
  if (!field.isMutable) {
    return '${field.constructorArgPrefix}_value.${field.name},';
  }

  return '''${field.constructorArgPrefix}${field.placeholderCheckExpression}
        ? _value.${field.name}
        // ignore: cast_nullable_to_non_nullable
        : ${field.name} as ${field.type},''';
}
