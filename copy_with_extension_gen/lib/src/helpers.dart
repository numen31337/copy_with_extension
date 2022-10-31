import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement;
import 'package:copy_with_extension_gen/builder.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
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

  final fields = <FieldInfo>[];

  for (final parameter in parameters) {
    final field = FieldInfo(
      parameter,
      element,
      isPositioned: parameter.isPositional,
    );

    fields.add(field);
  }

  return fields;
}

/// Restores the `CopyWith` annotation provided by the user.
CopyWithAnnotation readClassAnnotation(ConstantReader reader) {
  final generateCopyWithNull = reader.peek('copyWithNull')?.boolValue;
  final skipFields = reader.peek('skipFields')?.boolValue;
  final constructor = reader.peek('constructor')?.stringValue;

  return CopyWithAnnotation(
    copyWithNull: generateCopyWithNull ?? settings.copyWithNull,
    skipFields: skipFields ?? settings.skipFields,
    constructor: constructor,
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
