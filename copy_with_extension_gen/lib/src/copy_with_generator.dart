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
    ${classAnnotation.copyWith || classAnnotation.copyWithValues ? _copyWithProxyPart(
            classAnnotation.namedConstructor,
            classElement.name,
            typeParametersAnnotation,
            typeParametersNames,
            sortedFields,
            !classAnnotation.copyWithNull,
          ) : ""}
    
    extension ${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${classAnnotation.copyWith ? "_${classElement.name}CopyWithProxy$typeParametersNames get copyWith => _${classElement.name}CopyWithProxy$typeParametersNames(this);" : ""}

      ${_copyWithNullPart(typeAnnotation, sortedFields, classAnnotation.namedConstructor, !classAnnotation.copyWithNull)}
    }
    ''';
  }

  /// Generates a callable class function for copyWith(...).
  String _copyWithValuesPart(
    String typeAnnotation,
    List<FieldInfo> sortedFields,
    String? namedConstructor,
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
        /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `$typeAnnotation(...).copyWithNull(...)` to set certain fields to `null`. Prefer `$typeAnnotation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
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

    return '''
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
  ) {
    final typeAnnotation = type + typeParameterNames;
    final filteredFields = sortedFields.where((e) => !e.immutable);
    final nonNullableFields = filteredFields.where((e) => !e.nullable);
    final nullableFields =
        filteredFields.where((e) => !nonNullableFields.contains(e));

    final nonNullableFunctions = nonNullableFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => this(${e.name}: ${e.name});
    ''').join("\n");
    final nullableFunctions = nullableFields.map((e) => '''
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => ${e.name} == null ? _value.${privateCopyWithNull ? "_" : ""}copyWithNull(${e.name}: true) : this(${e.name}: ${e.name});
    ''').join("\n");

    return '''
      class _${type}CopyWithProxy$typeParameters {
        final $type$typeParameterNames _value;

        const _${type}CopyWithProxy(this._value);

        ${_copyWithValuesPart(typeAnnotation, sortedFields, namedConstructor)}

        $nullableFunctions

        $nonNullableFunctions
      }
    ''';
  }
}
