import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement, ParameterElement;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Represents a single class field with the additional metadata needed for code generation.
class FieldInfo {
  FieldInfo(
    ParameterElement element,
    ClassElement classElement, {
    required this.isPositioned,
  })  : name = element.name,
        type = element.type.getDisplayString(withNullability: true),
        fieldAnnotation = _readFieldAnnotation(element, classElement),
        nullable = element.type.nullabilitySuffix != NullabilitySuffix.none;

  final CopyWithFieldAnnotation fieldAnnotation;
  final String name;
  final bool nullable;
  final String type;

  /// if the field is positioned in the constructor

  final bool isPositioned;

  @override
  String toString() {
    return 'type:$type name:$name fieldAnnotation:$fieldAnnotation nullable:$nullable';
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithFieldAnnotation _readFieldAnnotation(
    ParameterElement element,
    ClassElement classElement,
  ) {
    const defaults = CopyWithFieldAnnotation.defaults();

    final fieldElement = classElement.getField(element.name);
    if (fieldElement is! FieldElement) {
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
