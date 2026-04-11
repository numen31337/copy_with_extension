// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/constant/value.dart' show DartObject;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' show DartType, DynamicType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/class_field_lookup.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Represents a single class field with the additional metadata needed for code generation.
class ConstructorParameterInfo {
  const ConstructorParameterInfo._({
    required this.constructorParamName,
    required this.name,
    required this.nullable,
    required this.type,
    required this.fieldAnnotation,
    required this.isPositioned,
    required this.classField,
    required this.classFieldNullable,
    required this.metadata,
    required this.isInherited,
  });

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
  final FieldElement? classField;

  /// Whether the corresponding class field is nullable.
  final bool classFieldNullable;

  /// Metadata annotations copied from the corresponding class field that should
  /// be reflected in generated `copyWith` methods.
  final List<String> metadata;

  /// `true` if this field is supplied by the generated superclass proxy.
  ///
  /// Fields introduced by unannotated intermediate classes are generated
  /// locally because the proxy only extends the nearest annotated superclass.
  final bool isInherited;

  @override
  String toString() {
    return 'type:$type name:$name fieldAnnotation:$fieldAnnotation nullable:$nullable';
  }

  /// Determines whether [fieldName] is inherited through the generated proxy
  /// superclass.
  static bool _isInherited(
    String fieldName,
    ClassElement classElement,
    ClassElement? annotatedSuper,
  ) {
    if (classElement.getField(fieldName) != null) return false;

    final declaredAboveClass = InheritanceTraversal.declaresField(
      classElement,
      fieldName,
      includeSelf: false,
    );
    if (!declaredAboveClass) {
      return false;
    }

    if (annotatedSuper == null) return true;

    return InheritanceTraversal.declaresField(annotatedSuper, fieldName);
  }

  /// Returns full type name including namespace for all nested type arguments.
  static String _fullTypeName(FormalParameterElement element) {
    final library = element.library;
    if (library is! LibraryElement) {
      return element.type.getDisplayString();
    }

    return ElementUtils.typeNameWithPrefix(library, element.type);
  }

  /// Restores the `CopyWithField` annotation provided by the user.
  static CopyWithFieldAnnotation _readFieldAnnotation(
    FieldElement? fieldElement,
    String fieldName,
    bool immutableDefault,
  ) {
    final defaults = CopyWithFieldAnnotation.defaults(
      immutable: immutableDefault,
    );

    final isPrivate = fieldName.startsWith('_');
    if (isPrivate) {
      // Treat private fields as immutable to avoid generating `copyWith`
      // parameters starting with an underscore. Using such parameters in a
      // public method results in analyzer errors.
      return const CopyWithFieldAnnotation(immutable: true);
    }

    if (fieldElement == null) {
      return defaults;
    }

    const checker = TypeChecker.typeNamed(CopyWithField);
    final annotation = checker.firstAnnotationOf(fieldElement);
    if (annotation is! DartObject) {
      return defaults;
    }

    final reader = ConstantReader(annotation);
    final immutable = reader.peek('immutable')?.boolValue;

    return CopyWithFieldAnnotation(immutable: immutable ?? defaults.immutable);
  }

  static bool _isNullable(DartType type) {
    return type.nullabilitySuffix != NullabilitySuffix.none ||
        type is DynamicType;
  }

  /// Restores metadata annotations for [field] that need to be transferred to
  /// generated parameters. Names in [annotations] are matched case-insensitively
  /// so callers don't need to specify multiple variants.
  static List<String> _readFieldMetadata(
    FieldElement? field,
    Set<String> annotations,
  ) {
    if (field == null || annotations.isEmpty) {
      return const [];
    }

    return field.metadata.annotations
        .where((annotation) {
          final name = annotation.element?.name;
          final enclosing = annotation.element?.enclosingElement?.name;
          if (name == 'CopyWithField' || enclosing == 'CopyWithField') {
            return false;
          }
          final nameLower = name?.toLowerCase();
          final enclosingLower = enclosing?.toLowerCase();
          return (nameLower != null && annotations.contains(nameLower)) ||
              (enclosingLower != null && annotations.contains(enclosingLower));
        })
        .map((annotation) => annotation.toSource())
        .toList();
  }
}

/// Builds [ConstructorParameterInfo] instances while sharing per-generation
/// field and inherited-field resolution.
class ConstructorParameterInfoFactory {
  ConstructorParameterInfoFactory({
    required ClassElement classElement,
    required ClassElement? annotatedSuper,
    required Set<String> annotations,
    required bool immutableDefault,
    ClassFieldLookupCache? fieldLookup,
  }) : _classElement = classElement,
       _annotatedSuper = annotatedSuper,
       _annotations = annotations,
       _immutableDefault = immutableDefault,
       _fieldLookup = fieldLookup ?? ClassFieldLookupCache(classElement);

  final ClassElement _classElement;
  final ClassElement? _annotatedSuper;
  final Set<String> _annotations;
  final bool _immutableDefault;
  final ClassFieldLookupCache _fieldLookup;
  final Map<String, bool> _inheritedByFieldName = <String, bool>{};

  ConstructorParameterInfo create(
    FormalParameterElement element, {
    required bool isPositioned,
    String? fieldName,
  }) {
    final resolvedFieldName = fieldName ?? element.displayName;
    final resolved = _ResolvedConstructorField.from(
      parameter: element,
      fieldName: resolvedFieldName,
      fieldLookup: _fieldLookup,
      annotations: _annotations,
      immutableDefault: _immutableDefault,
      isInherited: _isInherited(resolvedFieldName),
    );

    return ConstructorParameterInfo._(
      constructorParamName: element.displayName,
      name: resolvedFieldName,
      nullable: resolved.parameterNullable,
      type: resolved.parameterType,
      fieldAnnotation: resolved.fieldAnnotation,
      isPositioned: isPositioned,
      classField: resolved.classField,
      classFieldNullable: resolved.classFieldNullable,
      metadata: resolved.metadata,
      isInherited: resolved.isInherited,
    );
  }

  bool _isInherited(String fieldName) {
    return _inheritedByFieldName.putIfAbsent(
      fieldName,
      () => ConstructorParameterInfo._isInherited(
        fieldName,
        _classElement,
        _annotatedSuper,
      ),
    );
  }
}

class _ResolvedConstructorField {
  const _ResolvedConstructorField({
    required this.classField,
    required this.classFieldNullable,
    required this.fieldAnnotation,
    required this.metadata,
    required this.isInherited,
    required this.parameterNullable,
    required this.parameterType,
  });

  factory _ResolvedConstructorField.from({
    required FormalParameterElement parameter,
    required String fieldName,
    required ClassFieldLookupCache fieldLookup,
    required Set<String> annotations,
    required bool immutableDefault,
    required bool isInherited,
  }) {
    final classField = fieldLookup.find(fieldName);

    return _ResolvedConstructorField(
      classField: classField,
      classFieldNullable:
          classField != null &&
          ConstructorParameterInfo._isNullable(classField.type),
      fieldAnnotation: ConstructorParameterInfo._readFieldAnnotation(
        classField,
        fieldName,
        immutableDefault,
      ),
      metadata: ConstructorParameterInfo._readFieldMetadata(
        classField,
        annotations,
      ),
      isInherited: isInherited,
      parameterNullable: ConstructorParameterInfo._isNullable(parameter.type),
      parameterType: ConstructorParameterInfo._fullTypeName(parameter),
    );
  }

  final FieldElement? classField;
  final bool classFieldNullable;
  final CopyWithFieldAnnotation fieldAnnotation;
  final List<String> metadata;
  final bool isInherited;
  final bool parameterNullable;
  final String parameterType;
}
