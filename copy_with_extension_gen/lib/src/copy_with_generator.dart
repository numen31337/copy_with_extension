import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart'
    show
        ClassElement,
        ConstructorElement,
        Element,
        FieldElement,
        ParameterElement;
import 'package:analyzer/dart/element/nullability_suffix.dart';
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

    final ClassElement classElement = element;
    final generateCopyWithNull =
        annotation.read('generateCopyWithNull').boolValue;
    final namedConstructor = annotation.peek('namedConstructor')?.stringValue;

    final sortedFields =
        _sortedConstructorFields(classElement, namedConstructor);
    final typeParametersAnnotation = _typeParametersString(classElement, false);
    final typeParametersNames = _typeParametersString(classElement, true);
    final typeAnnotation = classElement.name + typeParametersNames;

    return '''
    extension ${classElement.name}CopyWith$typeParametersAnnotation on ${classElement.name}$typeParametersNames {
      ${_copyWithPart(typeAnnotation, sortedFields, namedConstructor)}
      ${generateCopyWithNull ? _copyWithNullPart(typeAnnotation, sortedFields, namedConstructor) : ""}
    }
    ''';
  }

  ///Returns parameter names or full parameters declaration declared by this class or an empty string.
  ///
  ///If `nameOnly` is `true`: `class MyClass<T extends String, Y>` returns `<T, Y>`.
  ///
  ///If `nameOnly` is `false`: `class MyClass<T extends String, Y>` returns `<T extends String, Y>`.
  String _typeParametersString(ClassElement classElement, bool nameOnly) {
    final names = classElement.typeParameters
        .map(
          (e) => nameOnly ? e.name : e.getDisplayString(withNullability: true),
        )
        .join(',');
    if (names.isNotEmpty) {
      return '<$names>';
    } else {
      return '';
    }
  }

  ///Returns constructor for the given type and optional named constructor name
  String _constructorFor(String typeAnnotation, String? namedConstructor) =>
      "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";

  ///Generates the complete `copyWith` function.
  String _copyWithPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
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
          return '$r ${v.name}: ${v.name},';
        } else {
          return '$r ${v.name}: ${v.name} ?? this.${v.name},';
        }
      },
    );

    return '''
        $typeAnnotation copyWith({$constructorInput}) {
          return ${_constructorFor(typeAnnotation, namedConstructor)}($paramsInput);
        }
    ''';
  }

  ///Generates the complete `copyWithNull` function.
  String _copyWithNullPart(
    String typeAnnotation,
    List<_FieldInfo> sortedFields,
    String? namedConstructor,
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
      $typeAnnotation copyWithNull({$nullConstructorInput}) {
        return ${_constructorFor(typeAnnotation, namedConstructor)}($nullParamsInput);
      }
    ''';
  }

  ///Generates a list of `_FieldInfo` for each class field that will be a part of the code generation process.
  ///The resulting array is sorted by the field name. `Throws` on error.
  List<_FieldInfo> _sortedConstructorFields(
    ClassElement element,
    String? constructorName,
  ) {
    // final named = element.getNamedConstructor(name);
    final constructor = constructorName != null
        ? element.getNamedConstructor(constructorName)
        : element.unnamedConstructor;

    if (constructor is! ConstructorElement) {
      if (constructorName != null) {
        throw 'Named Constructor $constructorName constructor is missing';
      } else {
        throw 'Default ${element.name} constructor is missing';
      }
    }

    final parameters = constructor.parameters;
    if (parameters.isEmpty) {
      throw 'Unnamed constructor for ${element.name} has no parameters';
    }

    for (final parameter in parameters) {
      if (!parameter.isNamed) {
        throw 'Unnamed constructor for ${element.name} contains unnamed parameter. Only named parameters are supported.';
      }
    }

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
  final bool nullable;

  _FieldInfo(ParameterElement element, ClassElement classElement)
      : name = element.name,
        type = element.type.getDisplayString(withNullability: true),
        immutable = _readFieldOptions(element, classElement).immutable,
        nullable = element.type.nullabilitySuffix != NullabilitySuffix.none;

  static CopyWithField _readFieldOptions(
    ParameterElement element,
    ClassElement classElement,
  ) {
    final fieldElement = classElement.getField(element.name);
    if (fieldElement is! FieldElement) {
      return const CopyWithField();
    }

    const checker = TypeChecker.fromRuntime(CopyWithField);
    final annotation = checker.firstAnnotationOf(fieldElement);
    if (annotation is! DartObject) {
      return const CopyWithField();
    }

    final reader = ConstantReader(annotation);
    final immutable = reader.read('immutable').literalValue as bool;

    return CopyWithField(immutable: immutable);
  }

  @override
  String toString() {
    return 'type:$type name:$name immutable:$immutable nullable:$nullable';
  }
}
