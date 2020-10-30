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

    final typeParametersAnnotation = _typeParametersString(classElement, false);
    final typeParametersNames = _typeParametersString(classElement, true);
    final typeAnnotation = classElement.name + typeParametersNames;

    return '''
    extension ${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${_copyWithPart(typeAnnotation, sortedFields)}
      ${generateCopyWithNull ? _copyWithNullPart(typeAnnotation, sortedFields) : ""}
    }
    ''';
  }

  ///Returns parameter names or full parameters declaration declared by this class or an empty string.
  ///
  ///If `nameOnly` is `true`: `class MyClass<T extends String, Y>` returns `<T, Y>`.
  ///
  ///If `nameOnly` is `false`: `class MyClass<T extends String, Y>` returns `<T extends String, Y>`.
  String _typeParametersString(ClassElement classElement, bool nameOnly) {
    assert(classElement is ClassElement);
    assert(nameOnly is bool);

    final names = classElement.typeParameters
        .map(
          (e) => nameOnly ? e.name : e.getDisplayString(withNullability: false),
        )
        .join(',');
    if (names.isNotEmpty) {
      return '<$names>';
    } else {
      return '';
    }
  }

  ///Generates the complete `copyWith` function.
  String _copyWithPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
  ) {
    assert(typeAnnotation is String && sortedFields is List<_FieldInfo>);

    final constructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable) {
          return '$r';
        } else if (v.required) {
          return '$r @required ${v.type} ${v.name},';
        } else {
          return '$r ${v.type} ${v.name},';
        }
      },
    );
    final paramsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable || v.required) {
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

  ///Generates the complete `copyWithNull` function.
  String _copyWithNullPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
  ) {
    assert(typeAnnotation is String && sortedFields is List<_FieldInfo>);

    final nullConstructorInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable) {
          return '$r';
        } else {
          return '$r bool ${v.name} = false,';
        }
      },
    );
    final nullParamsInput = sortedFields.fold<String>(
      '',
      (r, v) {
        if (v.immutable) {
          return '$r ${v.name}: ${v.name},';
        } else {
          return '$r ${v.name}: ${v.name} == true ? null : this.${v.name},';
        }
      },
    );

    return '''
      $typeAnnotation copyWithNull({$nullConstructorInput}) {
        return $typeAnnotation($nullParamsInput);
      }
    ''';
  }

  ///Generates a list of `_FieldInfo` for each class field that will be a part of the code generation process.
  ///The resulting array is sorted by the field name. `Throws` on error.
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

///Represents a single class field with the additional metadata needed for code generation.
class _FieldInfo {
  final String name;
  final String type;
  final bool immutable;
  final bool required;

  _FieldInfo(ParameterElement element, ClassElement classElement)
      : name = element.name,
        type = element.type.getDisplayString(withNullability: false),
        immutable = _readFieldOptions(element, classElement).immutable,
        required = _readFieldOptions(element, classElement).required,
        assert(element.name is String),
        assert(element.type.getDisplayString(withNullability: false) is String),
        assert(_readFieldOptions(element, classElement).immutable is bool),
        assert(_readFieldOptions(element, classElement).required is bool);

  static CopyWithField _readFieldOptions(
    ParameterElement element,
    ClassElement classElement,
  ) {
    assert(element is Element);
    assert(classElement is ClassElement);

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
    final required = reader.read('required').literalValue as bool;

    return CopyWithField(immutable: immutable, required: required);
  }

  @override
  String toString() {
    return 'type:$type name:$name immutable:$immutable required:$required';
  }
}
