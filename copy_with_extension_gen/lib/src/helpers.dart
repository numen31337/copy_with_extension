import 'package:analyzer/dart/ast/ast.dart'
    show
        ConstructorDeclaration,
        ConstructorFieldInitializer,
        NamedExpression,
        SimpleIdentifier,
        SuperConstructorInvocation;
import 'package:analyzer/dart/analysis/results.dart' show ParsedLibraryResult;
import 'package:analyzer/dart/element/element2.dart'
    show
        ClassElement2,
        ConstructorElement2,
        Element2,
        LibraryElement2,
        LibraryImport,
        PrefixElement2;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart'
    show DartType, ParameterizedType;
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/field_info.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, InvalidGenerationSourceError;

/// Generates a list of [ConstructorParameterInfo] objects representing the
/// constructor parameters that participate in `copyWith` generation.
///
/// Will throw an [InvalidGenerationSourceError] if the constructor cannot be
/// resolved or has no parameters.
List<ConstructorParameterInfo> constructorFields(
  ClassElement2 element,
  String? constructor, {
  ClassElement2? annotatedSuper,
}) {
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
  final paramFieldMap = _superInitializerFieldMap(targetConstructor);

  final fields = <ConstructorParameterInfo>[];

  for (final parameter in parameters) {
    final paramName = readElementNameOrThrow(parameter);
    final fieldName = paramFieldMap[paramName];

    final field = ConstructorParameterInfo(
      parameter,
      element,
      isPositioned: parameter.isPositional,
      annotatedSuper: annotatedSuper,
      fieldName: fieldName,
    );

    if (field.classFieldInfo != null) {
      fields.add(field);
    }
  }

  return fields;
}

/// Builds a map of constructor parameter names to their corresponding field
/// names when parameters are forwarded to a superclass with different names.
Map<String, String> _superInitializerFieldMap(ConstructorElement2 constructor) {
  final library = constructor.library2;
  final session = library.session;

  final parsed = session.getParsedLibraryByElement2(library);
  if (parsed is! ParsedLibraryResult) return const {};
  final declaration = parsed.getFragmentDeclaration(constructor.firstFragment);
  final node = declaration?.node;
  if (node is! ConstructorDeclaration) return const {};

  final result = <String, String>{};

  for (final initializer in node.initializers) {
    if (initializer is ConstructorFieldInitializer) {
      final fieldName = initializer.fieldName.name;
      final expression = initializer.expression;
      if (expression is SimpleIdentifier) {
        result[expression.name] = fieldName;
      }
    } else if (initializer is SuperConstructorInvocation) {
      for (final arg in initializer.argumentList.arguments) {
        if (arg is NamedExpression) {
          final fieldName = arg.name.label.name;
          final expr = arg.expression;
          if (expr is SimpleIdentifier) {
            result[expr.name] = fieldName;
          }
        }
      }
    }
  }

  return result;
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
      .map((e) => nameOnly ? readElementNameOrThrow(e) : e.displayString2())
      .join(',');
  if (names.isNotEmpty) {
    return '<$names>';
  } else {
    return '';
  }
}

/// Returns the name of [element] or throws an
/// [InvalidGenerationSourceError] if the element has no name.
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

/// Recursively builds the display name for [type] including any import
/// prefixes required to reference symbols from other libraries.
String typeNameWithPrefix(LibraryElement2 library, DartType type) {
  final nullability =
      type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

  if (type is ParameterizedType) {
    final element = type.element3;
    final name = element != null
        ? '${_prefixFor(library, element.library2)}${element.name3}'
        : displayStringWithoutNullability(type);

    if (type.typeArguments.isNotEmpty) {
      final args = type.typeArguments
          .map((t) => typeNameWithPrefix(library, t))
          .join(', ');
      return '$name<$args>$nullability';
    } else {
      return '$name$nullability';
    }
  }

  final displayName = displayStringWithoutNullability(type);
  return '${_prefixFor(library, type.element3?.library2)}$displayName$nullability';
}

/// Returns the import prefix for [targetLibrary] if one exists in [library].
String _prefixFor(LibraryElement2 library, LibraryElement2? targetLibrary) {
  if (targetLibrary == null) return '';
  final unit = library.fragments.first;
  for (final PrefixElement2 prefix in unit.prefixes) {
    for (final LibraryImport import in prefix.imports) {
      if (import.importedLibrary2 == targetLibrary) {
        final prefixName = prefix.name3;
        if (prefixName is String && prefixName.isNotEmpty) {
          return '$prefixName.';
        }
      }
    }
  }
  return '';
}

/// Returns the `displayString` of [type] without a trailing question mark.
String displayStringWithoutNullability(DartType type) {
  final displayString = type.getDisplayString();
  return displayString.endsWith('?')
      ? displayString.substring(0, displayString.length - 1)
      : displayString;
}
