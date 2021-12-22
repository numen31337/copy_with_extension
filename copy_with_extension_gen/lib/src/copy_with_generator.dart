import 'package:analyzer/dart/element/element.dart' show ClassElement, Element;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation, InvalidGenerationSourceError;

/// A `Generator` for `package:build_runner`
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Only classes can be annotated with "CopyWith". "$element" is not a ClassElement.',
        element: element,
      );
    }

    final ClassElement classElement = element;
    final classAnnotation = readClassAnnotation(annotation);

    final sortedFields =
        sortedConstructorFields(classElement, classAnnotation.namedConstructor);
    final typeParametersAnnotation = typeParametersString(classElement, false);
    final typeParametersNames = typeParametersString(classElement, true);
    final typeAnnotation = classElement.name + typeParametersNames;

    return '''
    ${_copyWithProxyPart(
      classAnnotation.namedConstructor,
      classElement.name,
      typeParametersAnnotation,
      typeParametersNames,
      sortedFields,
      !classAnnotation.copyWithNull,
      classAnnotation.skipFields,
    )}
    
    extension ${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${"_${classElement.name}CWProxy$typeParametersNames get copyWith => _${classElement.name}CWProxy$typeParametersNames(this);"}

      ${_copyWithNullPart(typeAnnotation, sortedFields, classAnnotation.namedConstructor, !classAnnotation.copyWithNull, classAnnotation.skipFields)}
    }
    ''';
  }

  /// Generates the callable class function for copyWith(...).
  String _copyWithValuesPart(
    String typeAnnotation,
    List<FieldInfo> sortedFields,
    String? namedConstructor,
    bool skipFields,
  ) {
    final constructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable) {
          return r;
        } else {
          final type = v.type.endsWith('?') ? v.type : '${v.type}?';
          return '$r $type ${v.name},';
        }
      },
    );
    final paramsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable) {
          return '$r ${v.name}: _value.${v.name},';
        } else {
          return '$r ${v.name}: ${v.name} ?? _value.${v.name},';
        }
      },
    );

    return '''
        /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `$typeAnnotation(...).copyWithNull(...)` to set certain fields to `null`.${skipFields ? "" : " Prefer `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support."}
        /// 
        /// Usage
        /// ```dart
        /// $typeAnnotation(...).copyWith(id: 12, name: "My name")
        /// ````
        $typeAnnotation call({$constructorInput}) {
          return ${constructorFor(typeAnnotation, namedConstructor)}($paramsInput);
        }
    ''';
  }

  /// Generates the complete `copyWithNull` function.
  String _copyWithNullPart(
    String typeAnnotation,
    List<FieldInfo> sortedFields,
    String? namedConstructor,
    bool private,
    bool skipFields,
  ) {
    /// Return if there is no nullable fields
    if (sortedFields.where((element) => element.nullable == true).isEmpty) {
      return '';
    }

    final nullConstructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable || !v.nullable) {
          return r;
        } else {
          return '$r bool ${v.name} = false,';
        }
      },
    );
    final nullParamsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable || !v.nullable) {
          return '$r ${v.name}: ${v.name},';
        } else {
          return '$r ${v.name}: ${v.name} == true ? null : this.${v.name},';
        }
      },
    );

    final description = private
        ? ""
        : '''
        /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it.${skipFields ? "" : " Prefer `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support."}
        ///
        /// Usage
        /// ```dart
        /// $typeAnnotation(...).copyWithNull(firstField: true, secondField: true)
        /// ````''';

    return '''
      $description
      $typeAnnotation ${private ? "_" : ""}copyWithNull({$nullConstructorInput}) {
        return ${constructorFor(typeAnnotation, namedConstructor)}($nullParamsInput);
      }
    ''';
  }

  /// Generates a `CopyWithProxy` class.
  String _copyWithProxyPart(
    String? namedConstructor,
    String type,
    String typeParameters,
    String typeParameterNames,
    List<FieldInfo> sortedFields,
    bool privateCopyWithNull,
    bool skipFields,
  ) {
    final typeAnnotation = type + typeParameterNames;
    final filteredFields = sortedFields.where((e) => !e.immutable);
    final nonNullableFields = filteredFields.where((e) => !e.nullable);
    final nullableFields =
        filteredFields.where((e) => !nonNullableFields.contains(e));

    final nonNullableFunctions =
        skipFields ? "" : nonNullableFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => this(${e.name}: ${e.name});
    ''').join("\n");
    final nullableFunctions = skipFields ? "" : nullableFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => ${e.name} == null ? _value.${privateCopyWithNull ? "_" : ""}copyWithNull(${e.name}: true) : this(${e.name}: ${e.name});
    ''').join("\n");

    return '''
      /// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOf$type.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored.${skipFields ? "" : " Prefer to copy the instance with a specific field changed that handles nullification of fields correctly, e.g. like this:`instanceOf$type.copyWith.fieldName(...)`"}
      class _${type}CWProxy$typeParameters {
        final $type$typeParameterNames _value;

        const _${type}CWProxy(this._value);

        ${_copyWithValuesPart(typeAnnotation, sortedFields, namedConstructor, skipFields)}

        $nullableFunctions

        $nonNullableFunctions
      }
    ''';
  }
}
