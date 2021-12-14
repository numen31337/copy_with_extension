import 'package:analyzer/dart/element/element.dart' show ClassElement, Element;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation;

/// A `Generator` for `package:build_runner`
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) throw '$element is not a ClassElement';

    final ClassElement classElement = element;
    final classAnnotation = readClassAnnotation(annotation);

    final sortedFields =
        sortedConstructorFields(classElement, classAnnotation.namedConstructor);
    final typeParametersAnnotation = typeParametersString(classElement, false);
    final typeParametersNames = typeParametersString(classElement, true);
    final typeAnnotation = classElement.name + typeParametersNames;

    return '''
    ${classAnnotation.copyWith ? _copyWithPart(
            classElement.name,
            typeParametersAnnotation,
            sortedFields,
            !classAnnotation.copyWithValues,
            !classAnnotation.copyWithNull,
          ) : ""}
    
    extension ${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${classAnnotation.copyWith ? "_${classElement.name}CopyWithProxy get copyWith => _${classElement.name}CopyWithProxy$typeParametersNames(this);" : ""}

      ${_copyWithValuesPart(typeAnnotation, sortedFields, classAnnotation.namedConstructor, !classAnnotation.copyWithValues)}

      ${_copyWithNullPart(typeAnnotation, sortedFields, classAnnotation.namedConstructor, !classAnnotation.copyWithNull)}
    }
    ''';
  }

  ///Generates the complete `_copyWithValuesPart` function.
  String _copyWithValuesPart(
    String typeAnnotation,
    List<FieldInfo> sortedFields,
    String? namedConstructor,
    bool private,
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
          return '$r ${v.name}: ${v.name},';
        } else {
          return '$r ${v.name}: ${v.name} ?? this.${v.name},';
        }
      },
    );

    return '''
        $typeAnnotation ${private ? "_" : ""}copyWithValues({$constructorInput}) {
          return ${constructorFor(typeAnnotation, namedConstructor)}($paramsInput);
        }
    ''';
  }

  ///Generates the complete `copyWithNull` function.
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

  String _copyWithPart(
    String type,
    String typeParameters,
    List<FieldInfo> sortedFields,
    bool privateCopyWithValues,
    bool privateCopyWithNull,
  ) {
    final filteredFields = sortedFields.where((e) => !e.immutable);
    final nonNullableFields = filteredFields.where((e) => !e.nullable);
    final nullableFields =
        filteredFields.where((e) => !nonNullableFields.contains(e));

    final nonNullableFunctions = nonNullableFields.map((e) => '''
    $type ${e.name}(${e.type} ${e.name}) => _value.${privateCopyWithValues ? "_" : ""}copyWithValues(${e.name}: ${e.name});
    ''').join("\n");
    final nullableFunctions = nullableFields.map((e) => '''
    $type ${e.name}(${e.type} ${e.name}) => ${e.name} == null ? _value.${privateCopyWithNull ? "_" : ""}copyWithNull(${e.name}: true) :  _value.${privateCopyWithValues ? "_" : ""}copyWithValues(${e.name}: ${e.name});
    ''').join("\n");

    return '''
      class _${type}CopyWithProxy$typeParameters {
        final $type _value;

        _${type}CopyWithProxy(this._value);

        $nullableFunctions

        $nonNullableFunctions
      }
    ''';
  }
}
