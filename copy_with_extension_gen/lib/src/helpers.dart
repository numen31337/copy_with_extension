import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, ConstructorElement2, Element2;
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, InvalidGenerationSourceError;

/// Generates a list of `FieldInfo` for each class field that will be a part of the code generation process.
/// The resulting array is sorted by the field name. `Throws` on error.
List<ConstructorParameterInfo> sortedConstructorFields(
  ClassElement2 element,
  String? constructor,
) {
  final targetConstructor = constructor != null
      ? element.getNamedConstructor2(constructor)
      : element.unnamedConstructor2;

  if (targetConstructor is! ConstructorElement2) {
    if (constructor != null) {
      throw InvalidGenerationSourceError(
        'Named Constructor "$constructor" constructor is missing.',
        element: element,
      );
    } else {
      throw InvalidGenerationSourceError(
        'Default constructor for $element is missing.',
        element: element,
      );
    }
  }

  final parameters = targetConstructor.formalParameters;
  if (parameters.isEmpty) {
    throw InvalidGenerationSourceError(
      'Unnamed constructor for $element has no parameters or missing.',
      element: element,
    );
  }

  final fields = <ConstructorParameterInfo>[];

  for (final parameter in parameters) {
    final field = ConstructorParameterInfo(
      parameter,
      element,
      isPositioned: parameter.isPositional,
    );

    fields.add(field);
  }

  return fields;
}

/// Restores the `CopyWith` annotation provided by the user.
CopyWithAnnotation readClassAnnotation(
  Settings settings,
  ConstantReader reader,
) {
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
String typeParametersString(ClassElement2 classElement, bool nameOnly) {
  final names = classElement.typeParameters2
      .map(
        (e) => nameOnly ? readElementNameOrThrow(e) : e.displayString2(),
      )
      .join(',');
  if (names.isNotEmpty) {
    return '<$names>';
  } else {
    return '';
  }
}

String readElementNameOrThrow(Element2 element) {
  final name = element.name3;
  if (name is String) {
    return name;
  } else {
    throw InvalidGenerationSourceError(
      'Name for $element is missing.',
      element: element,
    );
  }
}

/// Returns constructor for the given type and optional named constructor name. E.g. "TestConstructor" or "TestConstructor._private" when "_private" constructor name is provided.
String constructorFor(String typeAnnotation, String? namedConstructor) =>
    "$typeAnnotation${namedConstructor == null ? "" : ".$namedConstructor"}";
