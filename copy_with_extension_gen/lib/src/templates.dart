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
      /// Returns a callable class that can be used as follows: `instanceOf$className.copyWith(...)`${skipFields ? "" : " or like so:`instanceOf$className.copyWith.fieldName(...)`"}.
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
    /// Copies the object with the specified fields set to `null`. Passing `false` has no effect. Prefer `copyWith(field: null)`${skipFields ? '' : ' or `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support'}.
    ///
    /// Usage
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

      /// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOf$type.copyWith(...)`.${skipFields ? '' : ' Additionally contains functions for specific fields e.g. `instanceOf$type.copyWith.fieldName(...)`'}
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
        return '$r ${v.name}: _value.${v.name},';
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
        /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.${skipFields ? '' : ' You can also use `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.'}
        ///
        /// Usage
        /// ```dart
        /// $typeAnnotation(...).copyWith(id: 12, name: "My name")
        /// ```
        $typeAnnotation call({$constructorInput}) $constructorBody
    ''';
}
