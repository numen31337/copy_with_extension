import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement, FieldElement, ParameterElement;
import 'package:analyzer/dart/constant/value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Generates a list of `FieldInfo` for each class field that will be a part of the code generation process.
/// The resulting array is sorted by the field name. `Throws` on error.
List<FieldInfo> sortedConstructorFields(
  ClassElement element,
  String? constructorName,
) {
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

  final fields = parameters.map((v) => FieldInfo(v, element)).toList();
  fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

  return fields;
}

/// Restores the `CopyWithField` annotation provided by the user.
CopyWithField readFieldAnnotation(
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

/// Restores the `CopyWith` annotation provided by the user.
CopyWith readClassAnnotation(ConstantReader reader) {
  final generateCopyWithNull = reader.read('copyWithNull').boolValue;
  final generateCopyWithValues = reader.read('copyWithValues').boolValue;
  final generateCopyWith = reader.read('copyWith').boolValue;
  final useNamedConstructor = reader.peek('namedConstructor')?.stringValue;

  return CopyWith(
    copyWith: generateCopyWith,
    copyWithValues: generateCopyWithValues,
    copyWithNull: generateCopyWithNull,
    namedConstructor: useNamedConstructor,
  );
}

/// Returns parameter names or full parameters declaration declared by this class or an empty string.
///
/// If `nameOnly` is `true`: `class MyClass<T extends String, Y>` returns `<T, Y>`.
///
/// If `nameOnly` is `false`: `class MyClass<T extends String, Y>` returns `<T extends String, Y>`.
String typeParametersString(ClassElement classElement, bool nameOnly) {
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

/// Returns constructor for the given type and optional named constructor name. E.g. "TestConstructor" or "TestConstructor._private" when "_private" constructor name is provided.
String constructorFor(String typeAnnotation, String? namedConstructor) =>
    "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";
