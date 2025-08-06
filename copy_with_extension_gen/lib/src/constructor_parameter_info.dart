import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' show DynamicType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Represents a single class field with the additional metadata needed for code generation.
class ConstructorParameterInfo {
  ConstructorParameterInfo(
    FormalParameterElement element,
    ClassElement2 classElement, {
    required this.isPositioned,
    ClassElement2? annotatedSuper,
    String? fieldName,
    required Set<String> annotations,
  })  : name = fieldName ?? element.displayName,
        constructorParamName = element.displayName,
        fieldAnnotation = _readFieldAnnotation(element, classElement),
        classField = _lookupField(
          classElement,
          fieldName ?? element.displayName,
        ),
        metadata = _readFieldMetadata(
          _lookupField(
            classElement,
            fieldName ?? element.displayName,
          ),
          annotations,
        ),
        isInherited = _isInherited(
          fieldName ?? element.displayName,
          classElement,
          annotatedSuper,
        ),
        nullable = element.type.nullabilitySuffix != NullabilitySuffix.none ||
            element.type is DynamicType,
        type = _fullTypeName(element);

  /// Name of the parameter as declared in the constructor.
  final String constructorParamName;

  /// Parameter / field type.
  final String name;

  /// If the type is nullable. `dynamic` lacks a nullability flag but accepts
  /// `null`, so it's treated as nullable.
  final bool nullable;

  /// Type name with nullability flag.
  final String type;

  /// Annotation provided by the user with `CopyWithField`.
  final CopyWithFieldAnnotation fieldAnnotation;

  /// True if the field is positioned in the constructor.
  final bool isPositioned;

  /// Field element taken from the class itself. If `null`, the field with the
  /// given name wasn't found on the class or its superclasses.
  final FieldElement2? classField;

  /// Metadata annotations copied from the corresponding class field that should
  /// be reflected in generated `copyWith` methods.
  final List<String> metadata;

  /// `true` if this field is declared in a superclass rather than the current
  /// class. Used to annotate overridden members in generated proxies.
  final bool isInherited;

  /// Returns `true` if the corresponding class field is nullable.
  bool get classFieldNullable =>
      classField != null &&
      (classField!.type.nullabilitySuffix != NullabilitySuffix.none ||
          classField!.type is DynamicType);

  @override
  String toString() {
    return 'type:$type name:$name fieldAnnotation:$fieldAnnotation nullable:$nullable';
  }

  /// Determines whether [fieldName] is declared on a superclass of
  /// [classElement].
  static bool _isInherited(
    String fieldName,
    ClassElement2 classElement,
    ClassElement2? annotatedSuper,
  ) {
    if (classElement.getField2(fieldName) != null) return false;

    if (annotatedSuper != null) {
      if (annotatedSuper.getField2(fieldName) != null) return true;
      for (final type in annotatedSuper.allSupertypes) {
        if (type.element3.getField2(fieldName) != null) {
          return true;
        }
      }
      return false;
    }

    for (final type in classElement.allSupertypes) {
      if (type.element3.getField2(fieldName) != null) {
        return true;
      }
    }
    return false;
  }

  /// Returns full type name including namespace for all nested type arguments.
  static String _fullTypeName(FormalParameterElement element) {
    final library = element.library2;
    if (library is! LibraryElement2) {
      return element.type.getDisplayString();
    }

    return ElementUtils.typeNameWithPrefix(library, element.type);
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithFieldAnnotation _readFieldAnnotation(
    FormalParameterElement element,
    ClassElement2 classElement,
  ) {
    const defaults = CopyWithFieldAnnotation.defaults();

    final fieldName = element.displayName;
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

    return CopyWithFieldAnnotation(immutable: immutable ?? defaults.immutable);
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

  /// Restores metadata annotations for [field] that need to be transferred to
  /// generated parameters. Names in [annotations] are matched case-insensitively
  /// so callers don't need to specify multiple variants.
  static List<String> _readFieldMetadata(
    FieldElement2? field,
    Set<String> annotations,
  ) {
    if (field == null || annotations.isEmpty) return const [];

    final transferable = annotations.map((name) => name.toLowerCase()).toSet();

    return field.metadata2.annotations
        .where((annotation) {
          final name = annotation.element2?.name3;
          final enclosing = annotation.element2?.enclosingElement2?.name3;
          if (name == 'CopyWithField' || enclosing == 'CopyWithField') {
            return false;
          }
          final nameLower = name?.toLowerCase();
          final enclosingLower = enclosing?.toLowerCase();
          return (nameLower != null && transferable.contains(nameLower)) ||
              (enclosingLower != null && transferable.contains(enclosingLower));
        })
        .map((annotation) => annotation.toSource())
        .toList();
  }
}
