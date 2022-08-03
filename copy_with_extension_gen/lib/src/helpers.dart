import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, InvalidGenerationSourceError;

/// Generates a list of `FieldInfo` for each class field that will be a part of the code generation process.
/// The resulting array is sorted by the field name. `Throws` on error.
List<FieldInfo> sortedConstructorFields(
  ClassElement element,
  String? constructor,
) {
  final targetConstructor = constructor != null
      ? element.getNamedConstructor(constructor)
      : element.unnamedConstructor;

  if (targetConstructor is! ConstructorElement) {
    if (constructor != null) {
      throw InvalidGenerationSourceError(
        'Named Constructor "$constructor" constructor is missing.',
        element: element,
      );
    } else {
      throw InvalidGenerationSourceError(
        'Default constructor for "${element.name}" is missing.',
        element: element,
      );
    }
  }

  final parameters = targetConstructor.parameters;
  if (parameters.isEmpty) {
    throw InvalidGenerationSourceError(
      'Unnamed constructor for ${element.name} has no parameters or missing.',
      element: element,
    );
  }

  for (final parameter in parameters) {
    if (!parameter.isNamed) {
      final constructorName = targetConstructor.name.isEmpty
          ? 'Unnamed constructor'
          : 'Constructor "${targetConstructor.name}"';
      throw InvalidGenerationSourceError(
        '$constructorName for "${element.name}" contains unnamed parameter "${parameter.name}". Constructors annotated with "CopyWith" can contain only named parameters.',
        element: element,
      );
    }
  }

  final fields = parameters.map((v) => FieldInfo(v, element)).toList();
  fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

  return fields;
}

/// Restores the `CopyWith` annotation provided by the user.
CopyWith readClassAnnotation(ConstantReader reader) {
  final generateCopyWithNull = reader.read('copyWithNull').boolValue;
  final skipFields = reader.read('skipFields').boolValue;
  final constructor = reader.peek('constructor')?.stringValue;

  return CopyWith(
    copyWithNull: generateCopyWithNull,
    constructor: constructor,
    skipFields: skipFields,
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

extension IterableExtension<T> on Iterable<T> {
  T? get safeFirst => isEmpty ? null : first;
}
