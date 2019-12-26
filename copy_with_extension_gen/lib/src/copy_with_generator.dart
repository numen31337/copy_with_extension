import 'package:analyzer/dart/element/element.dart'
    show ClassElement, Element, ParameterElement, ConstructorElement;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen/source_gen.dart'
    show GeneratorForAnnotation, ConstantReader;

/// A `Generator` for `package:build_runner`
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) throw "$element is not a ClassElement";
    final classElement = element as ClassElement;
    final fields = _sortedConstructorFields(classElement);
    final constructorInput = fields.fold(
      "",
      (r, v) => "$r ${v.type} ${v.name},",
    );
    final paramsInput = fields.fold(
      "",
      (r, v) => "$r ${v.name}: ${v.name} ?? this.${v.name},",
    );
    final typeParameters =
        classElement.typeParameters.fold("", (r, v) => "$r ${v.name},").trim();
    String typeParametersInput = typeParameters.isEmpty
        ? ""
        : "<${typeParameters.substring(0, typeParameters.length - 1)}>";
    return '''extension ${classElement.name}CopyWithExtension$typeParametersInput on ${classElement.name}$typeParametersInput {
      ${classElement.name} copyWith({$constructorInput}) {
        return ${classElement.name}($paramsInput);
      }
    }''';
  }

  List<_FieldInfo> _sortedConstructorFields(ClassElement element) {
    assert(element is ClassElement);

    final constructor = element.unnamedConstructor;
    if (constructor is! ConstructorElement) {
      throw "Default ${element.name} constructor is missing";
    }

    final parameters = constructor.parameters;
    if (parameters is! List<ParameterElement> || parameters.isEmpty) {
      throw "Unnamed constructor for ${element.name} has no parameters";
    }

    parameters.forEach((parameter) {
      if (!parameter.isNamed) {
        throw "Unnamed constructor for ${element.name} contains unnamed parameter. Only named parameters are supported.";
      }
    });

    final fields = parameters.map((v) => _FieldInfo(v)).toList();
    fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

    return fields;
  }
}

class _FieldInfo {
  final String name;
  final String type;

  _FieldInfo(ParameterElement element)
      : this.name = element.name,
        this.type = element.type.name;
}
