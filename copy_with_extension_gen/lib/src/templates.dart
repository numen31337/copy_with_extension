import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';

/// Builds the entire extension code snippet.
/// This method assembles the proxy class and the extension declaration that is added to the generated file.
String extensionTemplate({
  required bool isPrivate,
  required String className,
  required String typeParametersAnnotation,
  required String typeParametersNames,
  required List<ConstructorParameterInfo> fields,
  required bool skipFields,
  required bool copyWithNull,
  required String? constructor,
}) {
  final typeAnnotation = className + typeParametersNames;
  final privacyPrefix = isPrivate ? "_" : "";
  final proxy = copyWithProxyTemplate(
    constructor,
    className,
    typeParametersAnnotation,
    typeParametersNames,
    fields,
    skipFields,
  );
  final copyWithNullBlock = copyWithNull
      ? copyWithNullTemplate(
          typeAnnotation,
          fields,
          constructor,
          skipFields,
        )
      : '';

  return '''
    $proxy

    extension $privacyPrefix\$${className}CopyWith$typeParametersAnnotation on $className$typeParametersNames {
      /// Returns a callable class used to build a new instance with modified fields.
      /// Example: `instanceOf$className.copyWith(...)`${skipFields ? "" : " or `instanceOf$className.copyWith.fieldName(...)`"}.
      // ignore: library_private_types_in_public_api
      _\$${className}CWProxy$typeParametersNames get copyWith => _\$${className}CWProxyImpl$typeParametersNames(this);

      $copyWithNullBlock
    }
    ''';
}

/// Generates the `copyWithNull` method.
String copyWithNullTemplate(
  String typeAnnotation,
  List<ConstructorParameterInfo> fields,
  String? constructor,
  bool skipFields,
) {
  // Return an empty string when the class has no nullable fields.
  if (fields.where((element) => element.nullable == true).isEmpty) {
    return '';
  }

  // Build the constructor parameter list. Only nullable and mutable fields need a boolean flag to specify nullification.
  final nullConstructorInput = fields.fold<String>(
    '',
    (r, v) {
      if (v.fieldAnnotation.immutable || !v.nullable) {
        return r;
      } else {
        return '$r bool ${v.name} = false,';
      }
    },
  );

  // Build the actual invocation parameters for the constructor call.
  final nullParamsInput = fields.fold<String>(
    '',
    (r, v) {
      if (v.fieldAnnotation.immutable || !v.nullable) {
        return '$r ${v.name}: ${v.name},';
      } else {
        return '$r ${v.name}: ${v.name} == true ? null : this.${v.name},';
      }
    },
  );

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
        return ${constructorFor(typeAnnotation, constructor)}($nullParamsInput);
      }
     ''';
}

/// Generates the proxy classes that power the `copyWith` API.
/// The proxy exposes both a `call` method and individual field setters.
String copyWithProxyTemplate(
  String? constructor,
  String type,
  String typeParameters,
  String typeParameterNames,
  List<ConstructorParameterInfo> fields,
  bool skipFields,
) {
  final typeAnnotation = type + typeParameterNames;
  final filteredFields = fields.where((e) => !e.fieldAnnotation.immutable);

  // Generate proxy methods for each mutable field. These methods allow modification of a single field via `instance.copyWith.fieldName(value)`.
  final nonNullableFunctions = skipFields ? '' : filteredFields.map((e) => '''
    @override
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => this(${e.name}: ${e.name});
    ''').join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface =
      skipFields ? '' : filteredFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name});
    ''').join('\n');

  return '''
      abstract class _\$${type}CWProxy$typeParameters {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(typeAnnotation, fields, constructor, skipFields, true)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf$type.copyWith(...)`${skipFields ? '' : ' or call `instanceOf$type.copyWith.fieldName(value)` for a single field'}.
      class _\$${type}CWProxyImpl$typeParameters implements _\$${type}CWProxy$typeParameterNames {
        const _\$${type}CWProxyImpl(this._value);

        final $type$typeParameterNames _value;

        $nonNullableFunctions

        @override
        ${copyWithValuesTemplate(typeAnnotation, fields, constructor, skipFields, false)}
      }
    ''';
}

/// Generates the body of the `call` method used by the proxy.
/// The returned snippet can be used either as an abstract interface (when [isAbstract] is `true`) or as a concrete implementation that instantiates the target class.
String copyWithValuesTemplate(
  String typeAnnotation,
  List<ConstructorParameterInfo> fields,
  String? constructor,
  bool skipFields,
  bool isAbstract,
) {
  // Build the parameter list for the generated function or abstract interface. Immutable fields are excluded entirely.
  final constructorInput = fields.fold<String>(
    '',
    (r, v) {
      if (v.fieldAnnotation.immutable) return r;

      if (isAbstract) {
        // When generating the interface, parameters are typed directly.
        return '$r ${v.type} ${v.name},';
      } else {
        // The implementation uses [\$CopyWithPlaceholder] to detect whether a parameter was passed.
        return '$r Object? ${v.name} = const \$CopyWithPlaceholder(),';
      }
    },
  );

  // Generate the parameters passed to the constructor when creating the new instance. Immutable fields are copied from the existing value.
  final paramsInput = fields.fold<String>(
    '',
    (r, v) {
      if (v.fieldAnnotation.immutable) {
        return v.isPositioned
            ? '$r _value.${v.name},'
            : '$r ${v.name}: _value.${v.name},';
      }

      return '''$r ${v.isPositioned ? '' : '${v.name}:'}
        ${v.name} == const \$CopyWithPlaceholder()
        ? _value.${v.name}
        // ignore: cast_nullable_to_non_nullable
        : ${v.name} as ${v.type},''';
    },
  );

  final constructorBody = isAbstract
      ? ''
      : '{ return ${constructorFor(typeAnnotation, constructor)}($paramsInput); }';

  return '''
        /// Creates a new instance with the provided field values.
        /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.${skipFields ? '' : ' To update a single field use `$typeAnnotation(...).copyWith.fieldName(value)`.'}
        ///
        /// Example:
        /// ```dart
        /// $typeAnnotation(...).copyWith(id: 12, name: "My name")
        /// ```
        $typeAnnotation call({$constructorInput}) $constructorBody
    ''';
}
