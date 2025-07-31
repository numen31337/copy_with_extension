import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart'
    show ParameterizedType, DartType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/helpers.dart'
    show readElementNameOrThrow;
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Class field info relevant for code generation.
class FieldInfo {
  FieldInfo({required this.name, required this.nullable, required this.type});

  /// Parameter / field type.
  final String name;

  /// If the type is nullable. `dynamic` is considered non-nullable as it doesn't have nullability flag.
  final bool nullable;

  /// Type name with nullability flag.
  final String type;

  /// True if the type is `dynamic`.
  bool get isDynamic => type == "dynamic";
}

/// Represents a single class field with the additional metadata needed for code generation.
class ConstructorParameterInfo extends FieldInfo {
  ConstructorParameterInfo(
    FormalParameterElement element,
    ClassElement2 classElement, {
    required this.isPositioned,
  })  : fieldAnnotation = _readFieldAnnotation(element, classElement),
        classFieldInfo =
            _classFieldInfo(readElementNameOrThrow(element), classElement),
        super(
          name: readElementNameOrThrow(element),
          nullable: element.type.nullabilitySuffix != NullabilitySuffix.none,
          type: _fullTypeName(element),
        );

  /// Annotation provided by the user with `CopyWithField`.
  final CopyWithFieldAnnotation fieldAnnotation;

  /// True if the field is positioned in the constructor
  final bool isPositioned;

  /// Info relevant to the given field taken from the class itself, as contrary to the constructor parameter.
  /// If `null`, the field with the given name wasn't found on the class.
  final FieldInfo? classFieldInfo;

  @override
  String toString() {
    return 'type:$type name:$name fieldAnnotation:$fieldAnnotation nullable:$nullable';
  }

  /// Returns the field info for the constructor parameter in the relevant class.
  static FieldInfo? _classFieldInfo(
    String fieldName,
    ClassElement2 classElement,
  ) {
    final field = _lookupField(classElement, fieldName);
    if (field == null) return null;

    return FieldInfo(
      name: readElementNameOrThrow(field),
      nullable: field.type.nullabilitySuffix != NullabilitySuffix.none,
      type: field.type.getDisplayString(),
    );
  }

  /// Returns full type name including namespace for all nested type arguments.
  static String _fullTypeName(FormalParameterElement element) {
    final library = element.library2;
    if (library is! LibraryElement2) {
      return element.type.getDisplayString();
    }

    return _typeNameWithPrefix(library, element.type);
  }

  /// Recursively builds the name for the `type` including import prefixes.
  static String _typeNameWithPrefix(LibraryElement2 library, DartType type) {
    final nullability =
        type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

    if (type is ParameterizedType) {
      final element = type.element3;
      final name = element != null
          ? '${_prefixFor(library, element.library2)}${element.name3}'
          : _displayStringWithoutNullability(type);

      if (type.typeArguments.isNotEmpty) {
        final args = type.typeArguments
            .map((t) => _typeNameWithPrefix(library, t))
            .join(', ');
        return '$name<$args>$nullability';
      } else {
        return '$name$nullability';
      }
    }

    final displayName = _displayStringWithoutNullability(type);
    return '${_prefixFor(library, type.element3?.library2)}$displayName$nullability';
  }

  /// Returns the import prefix for `targetLibrary` if one exists in `library`.
  static String _prefixFor(
    LibraryElement2 library,
    LibraryElement2? targetLibrary,
  ) {
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
  ///
  /// The analyzer's `withNullability` parameter is deprecated. To omit the
  /// nullability suffix we obtain the string with nullability information and
  /// strip the trailing `?` when present.
  static String _displayStringWithoutNullability(DartType type) {
    final displayString = type.getDisplayString();
    return displayString.endsWith('?')
        ? displayString.substring(0, displayString.length - 1)
        : displayString;
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithFieldAnnotation _readFieldAnnotation(
    FormalParameterElement element,
    ClassElement2 classElement,
  ) {
    const defaults = CopyWithFieldAnnotation.defaults();

    final fieldName = readElementNameOrThrow(element);
    final isPrivate = fieldName.startsWith('_');
    if (isPrivate) {
      // Treat private parameters as immutable to avoid generating `copyWith`
      // parameters starting with an underscore. Using such parameters in a
      // public method results in analyzer errors.
      return const CopyWithFieldAnnotation(immutable: true);
    }

    final fieldElement = _lookupField(classElement, fieldName);
    if (fieldElement is! FieldElement2) {
      return defaults;
    }

    const checker = TypeChecker.fromRuntime(CopyWithField);
    final annotation = checker.firstAnnotationOf(fieldElement);
    if (annotation is! DartObject) {
      return defaults;
    }

    final reader = ConstantReader(annotation);
    final immutable = reader.peek('immutable')?.boolValue;

    return CopyWithFieldAnnotation(
      immutable: immutable ?? defaults.immutable,
    );
  }

  /// Returns [FieldElement2] for [fieldName] searching the entire inheritance
  /// hierarchy starting from [classElement].
  static FieldElement2? _lookupField(
    ClassElement2 classElement,
    String fieldName,
  ) {
    final ownField = classElement.getField2(fieldName);
    if (ownField is FieldElement2) return ownField;

    for (final supertype in classElement.allSupertypes) {
      final candidate = supertype.element3.getField2(fieldName);
      if (candidate is FieldElement2) {
        return candidate;
      }
    }

    return null;
  }
}
