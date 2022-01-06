import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement, ParameterElement;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Represents a single class field with the additional metadata needed for code generation.
class FieldInfo {
  final String name;
  final String type;
  final bool immutable;
  final bool nullable;

  FieldInfo(ParameterElement element, ClassElement classElement)
      : name = element.name,
        type = element.type.getDisplayString(withNullability: true),
        immutable = _readFieldAnnotation(element, classElement).immutable,
        nullable = element.type.nullabilitySuffix != NullabilitySuffix.none;

  @override
  String toString() {
    return 'type:$type name:$name immutable:$immutable nullable:$nullable';
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithField _readFieldAnnotation(
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
    final immutable = reader.read('immutable').literalValue as bool?;

    return CopyWithField(
      immutable: immutable ?? const CopyWithField().immutable,
    );
  }
}
