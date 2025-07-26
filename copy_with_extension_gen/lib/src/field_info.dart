import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/element.dart'
    show ParameterElement, PrefixElement;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, FieldElement2, FormalParameterElement;
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
          type: element.type.getDisplayString(),
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
    final field = classElement.fields2
        .where((e) => readElementNameOrThrow(e) == fieldName)
        .fold<FieldElement2?>(null, (previousValue, element) => element);
    if (field == null) return null;

    return FieldInfo(
      name: readElementNameOrThrow(field),
      nullable: field.type.nullabilitySuffix != NullabilitySuffix.none,
      type: field.type.getDisplayString(),
    );
  }

  /// Returns full type name including namespace.
  static String _fullTypeName(ParameterElement element) {
    final displayName = element.type.getDisplayString(withNullability: true);

    final prefix = element.library?.prefixes.safeFirst;
    final prefixIsFromTheCorrectLibrary =
        prefix?.library.id != element.type.element?.library?.id;
    final namespace = prefix is PrefixElement && prefixIsFromTheCorrectLibrary
        ? prefix.name
        : null;

    return namespace is String ? "$namespace.$displayName" : displayName;
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithFieldAnnotation _readFieldAnnotation(
    FormalParameterElement element,
    ClassElement2 classElement,
  ) {
    const defaults = CopyWithFieldAnnotation.defaults();

    final fieldElement =
        classElement.getField2(readElementNameOrThrow(element));
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
}
