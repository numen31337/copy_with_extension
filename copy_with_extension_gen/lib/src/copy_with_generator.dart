import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart'
    show
        ClassElement,
        ConstructorElement,
        Element,
        FieldElement,
        ParameterElement;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation, TypeChecker;

/// A `Generator` for `package:build_runner`
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) throw '$element is not a ClassElement';
    final classElement = element as ClassElement;
    final sortedFields = _sortedConstructorFields(classElement);
    final generateCopyWithNull =
        annotation.read('generateCopyWithNull').boolValue;

    final typeParametersAnnotation = _typeParametersAnnotation(classElement);
    final typeParametersNames = _typeParametersNames(classElement);
    final typeAnnotation = classElement.name + typeParametersNames;

    return '''
    extension ${classElement.name}CopyWithExtension$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${_copyWithPart(typeAnnotation, sortedFields)}
      ${generateCopyWithNull ? _copyWithNullPart(typeAnnotation, sortedFields) : ""}
    }
    ''';
  }

  String _typeParametersNames(ClassElement classElement) {
    final names = classElement.typeParameters.map((e) => e.name).join(',');
    if (names.isNotEmpty) {
      return '<$names>';
    } else {
      return '';
    }
  }

  String _typeParametersAnnotation(ClassElement classElement) {
    final classDisplayString =
        classElement.getDisplayString(withNullability: false);
    final startIndex = classDisplayString.indexOf('<');
    final endIndex = classDisplayString.indexOf('>');

    if (startIndex != -1 && endIndex != -1) {
      return classDisplayString.substring(
        startIndex,
        endIndex + 1,
      );
    } else {
      return '';
    }
  }

  String _copyWithPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
  ) {
    final constructorInput = sortedFields.fold(
      '',
      (r, v) {
        if (v.immutable) {
          return '$r';
        } else {
          return '$r ${v.type} ${v.name},';
        }
      },
    );
    final paramsInput = sortedFields.fold(
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
        $typeAnnotation copyWith({$constructorInput}) {
          return $typeAnnotation($paramsInput);
        }
    ''';
  }

  String _copyWithNullPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
  ) {
    final nullConstructorInput = sortedFields.fold(
      '',
      (r, v) => '$r bool ${v.name} = false,',
    );
    final nullParamsInput = sortedFields.fold(
      '',
      (r, v) => '$r ${v.name}: ${v.name} == true ? null : this.${v.name},',
    );

    return '''
      $typeAnnotation copyWithNull({$nullConstructorInput}) {
        return $typeAnnotation($nullParamsInput);
      }
    ''';
  }

  List<_FieldInfo> _sortedConstructorFields(ClassElement element) {
    assert(element is ClassElement);

    final constructor = element.unnamedConstructor;
    if (constructor is! ConstructorElement) {
      throw 'Default ${element.name} constructor is missing';
    }

    final parameters = constructor.parameters;
    if (parameters is! List<ParameterElement> || parameters.isEmpty) {
      throw 'Unnamed constructor for ${element.name} has no parameters';
    }

    parameters.forEach((parameter) {
      if (!parameter.isNamed) {
        throw 'Unnamed constructor for ${element.name} contains unnamed parameter. Only named parameters are supported.';
      }
    });

    final fields = parameters.map((v) => _FieldInfo(v, element)).toList();
    fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

    return fields;
  }
}

class _FieldInfo {
  final String name;
  final String type;
  final bool immutable;

  _FieldInfo(ParameterElement element, ClassElement classElement)
      : name = element.name,
        type = element.type.getDisplayString(withNullability: false),
        immutable = _readFieldOptions(element, classElement).immutable;

  static CopyWithField _readFieldOptions(
    ParameterElement element,
    ClassElement classElement,
  ) {
    final fieldElement = classElement.getField(element.name);
    if (fieldElement is! FieldElement) {
      return CopyWithField();
    }

    final checker = TypeChecker.fromRuntime(CopyWithField);
    final annotation = checker.firstAnnotationOf(fieldElement);
    if (annotation is! DartObject) {
      return CopyWithField();
    }

    final reader = ConstantReader(annotation);
    final immutable = reader.read('immutable').literalValue as bool;

    return CopyWithField(immutable: immutable);
  }

  @override
  String toString() {
    return 'type:$type name:$name immutable:$immutable';
  }
}
