import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ParameterElement;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';

/// Represents a single class field with the additional metadata needed for code generation.
class FieldInfo {
  final String name;
  final String type;
  final bool immutable;
  final bool nullable;

  FieldInfo(ParameterElement element, ClassElement classElement)
      : name = element.name,
        type = element.type.getDisplayString(withNullability: true),
        immutable = readFieldAnnotation(element, classElement).immutable,
        nullable = element.type.nullabilitySuffix != NullabilitySuffix.none;

  @override
  String toString() {
    return 'type:$type name:$name immutable:$immutable nullable:$nullable';
  }
}
