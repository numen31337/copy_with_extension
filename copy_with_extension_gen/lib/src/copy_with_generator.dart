import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation, InvalidGenerationSourceError;

/// A `Generator` for `package:build_runner`
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  CopyWithGenerator(this.settings) : super();

  Settings settings;

  /// Generates the `copyWith` extension code for the annotated [element].
  ///
  /// The method validates the target class, gathers all constructor
  /// parameters and user provided settings, and returns the source code for
  /// the extension as a string.
  @override
  String generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'Only classes can be annotated with "CopyWith". "$element" is not a ClassElement.',
        element: element,
      );
    }

    final ClassElement2 classElement = element;
    final privacyPrefix = element.isPrivate ? "_" : "";
    final classAnnotation = readClassAnnotation(settings, annotation);

    final className = readElementNameOrThrow(classElement);
    final sortedFields =
        sortedConstructorFields(classElement, classAnnotation.constructor);
    final typeParametersAnnotation = typeParametersString(classElement, false);
    final typeParametersNames = typeParametersString(classElement, true);
    final typeAnnotation = className + typeParametersNames;

    // Verify that constructor and class field nullability match. The generator
    // does not support a non-nullable constructor parameter pointing to a
    // nullable class field.
    for (final field in sortedFields) {
      if (field.classFieldInfo != null &&
          field.nullable == false &&
          field.classFieldInfo?.nullable == true) {
        throw InvalidGenerationSourceError(
          'The constructor parameter "${field.name}" is not nullable, whereas the corresponding class field is nullable. This use case is not supported.',
          element: element,
        );
      }
    }

    // Compose all generated pieces into a single extension.
    // Generate the final method including documentation.
    return '''
    ${_copyWithProxyPart(
      classAnnotation.constructor,
      className,
      typeParametersAnnotation,
      typeParametersNames,
      sortedFields,
      classAnnotation.skipFields,
    )}
    
    extension $privacyPrefix\$${className}CopyWith$typeParametersAnnotation on $className$typeParametersNames {
      /// Returns a callable class that can be used as follows: `instanceOf$className.copyWith(...)`${classAnnotation.skipFields ? "" : " or like so:`instanceOf$className.copyWith.fieldName(...)`"}.
      // ignore: library_private_types_in_public_api
      ${"_\$${className}CWProxy$typeParametersNames get copyWith => _\$${className}CWProxyImpl$typeParametersNames(this);"}

      ${classAnnotation.copyWithNull ? _copyWithNullPart(typeAnnotation, sortedFields, classAnnotation.constructor, classAnnotation.skipFields) : ""}
    }
    ''';
  }

  /// Generates the complete `copyWithNull` function.
  String _copyWithNullPart(
    String typeAnnotation,
    List<ConstructorParameterInfo> sortedFields,
    String? constructor,
    bool skipFields,
  ) {
    /// Return an empty string when the class has no nullable fields.
    if (sortedFields.where((element) => element.nullable == true).isEmpty) {
      return '';
    }

    // Build the constructor parameter list. Only nullable and mutable
    // fields need a boolean flag to specify nullification.
    final nullConstructorInput = sortedFields.fold<String>(
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
    final nullParamsInput = sortedFields.fold<String>(
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
    /// Copies the object with the specified fields set to `null`. Passing `false` has no effect. Prefer `copyWith(field: null)`${skipFields ? "" : " or `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support"}.
    ///
    /// Usage
    /// ```dart
    /// $typeAnnotation(...).copyWithNull(firstField: true, secondField: true)
    /// ````''';

    return '''
      $description
      $typeAnnotation copyWithNull({$nullConstructorInput}) {
        return ${constructorFor(typeAnnotation, constructor)}($nullParamsInput);
      }
     ''';
  }

  /// Generates a `CopyWithProxy` class.
  ///
  /// The proxy exposes a `call` method as well as individual methods for each
  /// mutable field (unless [skipFields] is true). These methods delegate the
  /// actual object copying to `_copyWithValuesPart`.
  String _copyWithProxyPart(
    String? constructor,
    String type,
    String typeParameters,
    String typeParameterNames,
    List<ConstructorParameterInfo> sortedFields,
    bool skipFields,
  ) {
    final typeAnnotation = type + typeParameterNames;
    final filteredFields =
        sortedFields.where((e) => !e.fieldAnnotation.immutable);

    // Generate proxy methods for each mutable field. These methods allow
    // modification of a single field via `instance.copyWith.fieldName(value)`.
    final nonNullableFunctions = skipFields ? "" : filteredFields.map((e) => '''
    @override
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => this(${e.name}: ${e.name});
    ''').join("\n");

    // Interface used by the proxy class. It mirrors the proxy methods above.
    final nonNullableFunctionsInterface =
        skipFields ? "" : filteredFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name});
    ''').join("\n");

    return '''
      abstract class _\$${type}CWProxy$typeParameters {
        $nonNullableFunctionsInterface

        ${_copyWithValuesPart(typeAnnotation, sortedFields, constructor, skipFields, true)};
      }

      /// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOf$type.copyWith(...)`.${skipFields ? "" : " Additionally contains functions for specific fields e.g. `instanceOf$type.copyWith.fieldName(...)`"}
      class _\$${type}CWProxyImpl$typeParameters implements _\$${type}CWProxy$typeParameterNames {
        const _\$${type}CWProxyImpl(this._value);

        final $type$typeParameterNames _value;

        $nonNullableFunctions

        @override
        ${_copyWithValuesPart(typeAnnotation, sortedFields, constructor, skipFields, false)}
      }
    ''';
  }

  /// Generates the callable class function for `copyWith(...)`.
  ///
  /// This method constructs both the interface and the implementation of the
  /// proxy's `call` method. When [isAbstract] is true only the method signature
  /// is returned; otherwise a full implementation that instantiates the target
  /// class with the provided parameters is created.
  String _copyWithValuesPart(
    String typeAnnotation,
    List<ConstructorParameterInfo> sortedFields,
    String? constructor,
    bool skipFields,
    bool isAbstract,
  ) {
    // Build the parameter list for the generated function or abstract
    // interface. Immutable fields are excluded entirely.
    final constructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.fieldAnnotation.immutable) return r; // Skip the field

        if (isAbstract) {
          // When generating the interface, parameters are typed directly.
          return '$r ${v.type} ${v.name},';
        } else {
          // The implementation uses [\$CopyWithPlaceholder] to detect
          // whether a parameter was passed.
          return '$r Object? ${v.name} = const \$CopyWithPlaceholder(),';
        }
      },
    );

    // Generate the parameters passed to the constructor when creating the
    // new instance. Immutable fields are copied from the existing value.
    final paramsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.fieldAnnotation.immutable) {
          return '$r ${v.name}: _value.${v.name},';
        }

        return '''$r ${v.isPositioned ? "" : '${v.name}:'}
        ${v.name} == const \$CopyWithPlaceholder()
        ? _value.${v.name}
        // ignore: cast_nullable_to_non_nullable
        : ${v.name} as ${v.type},''';
      },
    );

    final constructorBody = isAbstract
        ? ""
        : "{ return ${constructorFor(typeAnnotation, constructor)}($paramsInput); }";

    return '''
        /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.${skipFields ? "" : " You can also use `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support."}
        /// 
        /// Usage
        /// ```dart
        /// $typeAnnotation(...).copyWith(id: 12, name: "My name")
        /// ````
        $typeAnnotation call({$constructorInput}) $constructorBody
    ''';
  }
}
