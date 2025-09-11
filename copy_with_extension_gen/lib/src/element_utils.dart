import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart'
    show DartType, ParameterizedType;

/// Utilities for working with analyzer elements and types.
class ElementUtils {
  const ElementUtils._();

  /// Returns parameter names or full parameters declaration declared by this
  /// class or an empty string.
  ///
  /// If [nameOnly] is `true`: `class MyClass<T extends String, Y>` returns
  /// `<T, Y>`.
  ///
  /// If [nameOnly] is `false`: `class MyClass<T extends String, Y>` returns
  /// `<T extends String, Y>`.
  static String typeParametersString(ClassElement classElement, bool nameOnly) {
    final names = classElement.typeParameters
        .map((e) => nameOnly ? e.displayName : e.displayString())
        .join(',');
    return names.isNotEmpty ? '<$names>' : '';
  }

  /// Recursively builds the display name for [type] including any import
  /// prefixes required to reference symbols from other libraries.
  static String typeNameWithPrefix(LibraryElement library, DartType type) {
    final nullability =
        type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

    final alias = type.alias;
    if (alias != null) {
      final aliasElement = alias.element;
      final aliasName =
          '${libraryImportPrefix(library, aliasElement.library)}${aliasElement.name}';
      if (alias.typeArguments.isNotEmpty) {
        final args = alias.typeArguments
            .map((t) => typeNameWithPrefix(library, t))
            .join(', ');
        return '$aliasName<$args>$nullability';
      }
      return '$aliasName$nullability';
    }

    if (type is ParameterizedType) {
      final element = type.element;
      final name = element != null
          ? '${libraryImportPrefix(library, element.library)}${element.name}'
          : displayStringWithoutNullability(type);

      if (type.typeArguments.isNotEmpty) {
        final args = type.typeArguments
            .map((t) => typeNameWithPrefix(library, t))
            .join(', ');
        return '$name<$args>$nullability';
      }
      return '$name$nullability';
    }

    final displayName = displayStringWithoutNullability(type);
    return '${libraryImportPrefix(library, type.element?.library)}$displayName$nullability';
  }

  /// Returns the import prefix for [targetLibrary] if one exists in [library].
  static String libraryImportPrefix(
      LibraryElement library, LibraryElement? targetLibrary) {
    if (targetLibrary == null) return '';
    final unit = library.fragments.first;
    for (final PrefixElement prefix in unit.prefixes) {
      for (final LibraryImport import in prefix.imports) {
        if (import.importedLibrary == targetLibrary) {
          final prefixName = prefix.name;
          if (prefixName is String && prefixName.isNotEmpty) {
            return '$prefixName.';
          }
        }
      }
    }
    return '';
  }

  /// Returns the `displayString` of [type] without a trailing question mark.
  static String displayStringWithoutNullability(DartType type) {
    final displayString = type.getDisplayString();
    return displayString.endsWith('?')
        ? displayString.substring(0, displayString.length - 1)
        : displayString;
  }
}
