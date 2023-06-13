import 'package:analyzer/dart/element/element.dart'
    show ClassElement, Element, ElementKind;
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

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement && !_isTypedefRecord(element)) {
      throw InvalidGenerationSourceError(
        'Only classes can be annotated with "CopyWith". "$element" is not a ClassElement.',
        element: element,
      );
    }

    final ClassElement classElement = element;
    final privacyPrefix = element.isPrivate ? "_" : "";
    final classAnnotation = readClassAnnotation(settings, annotation);

    final sortedFields =
        sortedConstructorFields(classElement, classAnnotation.constructor);
    final typeParametersAnnotation = typeParametersString(classElement, false);
    final typeParametersNames = typeParametersString(classElement, true);
    final typeAnnotation = classElement.name + typeParametersNames;

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

    return '''
    ${_copyWithProxyPart(
      classAnnotation.constructor,
      classElement.name,
      typeParametersAnnotation,
      typeParametersNames,
      sortedFields,
      classAnnotation.skipFields,
    )}
    
    extension $privacyPrefix\$${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      /// Returns a callable class that can be used as follows: `instanceOf${classElement.name}.copyWith(...)`${classAnnotation.skipFields ? "" : " or like so:`instanceOf${classElement.name}.copyWith.fieldName(...)`"}.
      // ignore: library_private_types_in_public_api
      ${"_\$${classElement.name}CWProxy$typeParametersNames get copyWith => _\$${classElement.name}CWProxyImpl$typeParametersNames(this);"}

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
    /// Return if there is no nullable fields
    if (sortedFields.where((element) => element.nullable == true).isEmpty) {
      return '';
    }

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
    /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`${skipFields ? "" : " or `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support"}.
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

    final nonNullableFunctions = skipFields ? "" : filteredFields.map((e) => '''
    @override
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => this(${e.name}: ${e.name});
    ''').join("\n");
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

  /// Generates the callable class function for copyWith(...).
  String _copyWithValuesPart(
    String typeAnnotation,
    List<ConstructorParameterInfo> sortedFields,
    String? constructor,
    bool skipFields,
    bool isAbstract,
  ) {
    final constructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.fieldAnnotation.immutable) return r; // Skip the field

        if (isAbstract) {
          final type =
              v.type.endsWith('?') || v.isDynamic ? v.type : '${v.type}?';
          return '$r $type ${v.name},';
        } else {
          return '$r Object? ${v.name} = const \$CopyWithPlaceholder(),';
        }
      },
    );

    final paramsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.fieldAnnotation.immutable) {
          return '$r ${v.name}: _value.${v.name},';
        }

        final nullCheckForNonNullable =
            v.nullable ? "" : "|| ${v.name} == null";

        return '''$r ${v.isPositioned ? "" : '${v.name}:'}
        ${v.name} == const \$CopyWithPlaceholder() $nullCheckForNonNullable
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

bool _isTypedefRecord(Element e) {
  // TODO: fileds must be of Records' type as well
  return e.kind != ElementKind.TYPE_ALIAS;
}
