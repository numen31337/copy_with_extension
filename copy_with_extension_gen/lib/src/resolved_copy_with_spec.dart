// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/field_resolution_config.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, InvalidGenerationSourceError, TypeChecker;

const _copyWithChecker = TypeChecker.typeNamed(CopyWith);

/// Builds the fully resolved generator model for a single `@CopyWith` target.
///
/// This context owns the one-time resolution and validation step so templates
/// can render from an already-consistent model instead of re-deriving rules.
class CopyWithGenerationContext {
  const CopyWithGenerationContext({
    required this.classElement,
    required this.annotation,
    required this.settings,
  });

  final ClassElement classElement;
  final CopyWithAnnotation annotation;
  final Settings settings;

  /// Resolves constructor and per-field generation behavior into a single
  /// spec consumed by the templates.
  Future<ResolvedCopyWithSpec> resolve() async {
    final result = await ConstructorUtils.constructorFields(
      classElement,
      annotation.constructor,
      FieldResolutionConfig(
        annotations: settings.annotations,
        immutableDefault: annotation.immutableFields,
      ),
    );
    final fields = result.fields;
    _validateFieldNullability(fields);

    final resolvedFields = fields
        .map(ResolvedCopyWithField.from)
        .toList(growable: false);
    final categorized = _CategorizedFields.from(
      resolvedFields,
      skipFields: annotation.skipFields,
    );
    _validateCopyWithNullInheritance(categorized.uniqueNullableMutableFields);

    return ResolvedCopyWithSpec._(
      isPrivate: classElement.isPrivate,
      className: classElement.displayName,
      typeParametersAnnotation: ElementUtils.typeParametersString(
        classElement,
        false,
      ),
      typeParametersNames: ElementUtils.typeParametersString(
        classElement,
        true,
      ),
      constructorName: result.constructorName,
      skipFields: annotation.skipFields,
      generatesCopyWithNull: annotation.copyWithNull,
      constructorFields: resolvedFields,
      uniqueFields: categorized.uniqueFields,
      uniqueMutableFields: categorized.uniqueMutableFields,
      uniqueNullableMutableFields: categorized.uniqueNullableMutableFields,
      proxyMethodFields: categorized.proxyMethodFields,
    );
  }

  /// `copyWithNull` is generated on the extension rather than the proxy, so a
  /// subclass that does not generate it resolves the call to the superclass
  /// extension instead of failing: the call keeps compiling but returns the
  /// superclass type and drops subclass fields. Annotation options are not
  /// inherited, so fail the build rather than let that happen silently.
  void _validateCopyWithNullInheritance(
    List<ResolvedCopyWithField> nullableMutableFields,
  ) {
    if (annotation.copyWithNull || nullableMutableFields.isEmpty) return;
    if (!_annotatedSuperEnablesCopyWithNull()) return;

    throw InvalidGenerationSourceError(
      'Class "${classElement.displayName}" has nullable fields and extends a class annotated with `@CopyWith(copyWithNull: true)`, but does not enable `copyWithNull` itself. Annotation options are not inherited. Add `@CopyWith(copyWithNull: true)` to this class, or enable `copy_with_null` globally in `build.yaml`.',
      element: classElement,
    );
  }

  /// Whether the nearest `@CopyWith` annotated superclass enables
  /// `copyWithNull`.
  bool _annotatedSuperEnablesCopyWithNull() {
    var supertype = classElement.supertype;
    while (supertype != null) {
      final element = supertype.element;
      if (element is! ClassElement) return false;

      final annotation = _copyWithChecker.firstAnnotationOf(element);
      if (annotation != null) {
        return AnnotationUtils.readClassAnnotation(
          settings,
          ConstantReader(annotation),
        ).copyWithNull;
      }
      supertype = element.supertype;
    }
    return false;
  }

  void _validateFieldNullability(List<ConstructorParameterInfo> fields) {
    for (final field in fields) {
      if (field.classField != null &&
          field.nullable == false &&
          field.classFieldNullable) {
        throw InvalidGenerationSourceError(
          'Constructor parameter "${field.name}" is non-nullable, but the corresponding class field is nullable. Make both nullable or both non-nullable.',
          element: classElement,
        );
      }
    }
  }
}

/// Resolved field model used by the templates.
///
/// Built from a [ConstructorParameterInfo]. Stores only the data the spec
/// actually exposes; resolution-only details (like the class field element)
/// stay on [ConstructorParameterInfo].
class ResolvedCopyWithField {
  const ResolvedCopyWithField._({
    required this.name,
    required this.type,
    required this.nullable,
    required this.isMutable,
    required this.isPositioned,
    required this.constructorParamName,
    required this.metadata,
  });

  /// Projects a [ConstructorParameterInfo] into the spec-level view.
  factory ResolvedCopyWithField.from(ConstructorParameterInfo parameter) {
    return ResolvedCopyWithField._(
      name: parameter.name,
      type: parameter.type,
      nullable: parameter.nullable,
      isMutable: !parameter.fieldAnnotation.immutable,
      isPositioned: parameter.isPositioned,
      constructorParamName: parameter.constructorParamName,
      metadata: parameter.metadata,
    );
  }

  final String name;
  final String type;
  final bool nullable;
  final bool isMutable;
  final bool isPositioned;
  final String constructorParamName;
  final List<String> metadata;

  bool get supportsCopyWithNull => nullable && isMutable;

  /// The conditional expression that tests whether the parameter was
  /// explicitly supplied by the caller. Non-nullable fields include an
  /// additional `|| $name == null` guard so that passing `null` for a
  /// non-nullable parameter is treated as "not supplied".
  String get placeholderCheckExpression =>
      nullable
          ? '$name == const \$CopyWithPlaceholder()'
          : '$name == const \$CopyWithPlaceholder() || $name == null';

  /// Metadata annotations formatted as a prefix for generated parameters.
  /// Returns an empty string when there are no annotations.
  String get annotationPrefix =>
      metadata.isEmpty ? '' : '${metadata.join(' ')} ';

  /// Constructor argument prefix for named parameters (e.g. `fieldName: `),
  /// empty for positional parameters.
  String get constructorArgPrefix =>
      isPositioned ? '' : '$constructorParamName: ';
}

/// Fully resolved generator input consumed by rendering templates.
class ResolvedCopyWithSpec {
  ResolvedCopyWithSpec._({
    required this.isPrivate,
    required this.className,
    required this.typeParametersAnnotation,
    required this.typeParametersNames,
    required this.constructorName,
    required this.skipFields,
    required this.generatesCopyWithNull,
    required List<ResolvedCopyWithField> constructorFields,
    required List<ResolvedCopyWithField> uniqueFields,
    required List<ResolvedCopyWithField> uniqueMutableFields,
    required List<ResolvedCopyWithField> uniqueNullableMutableFields,
    required List<ResolvedCopyWithField> proxyMethodFields,
  }) : constructorFields = List<ResolvedCopyWithField>.unmodifiable(
         constructorFields,
       ),
       uniqueFields = List<ResolvedCopyWithField>.unmodifiable(uniqueFields),
       uniqueMutableFields = List<ResolvedCopyWithField>.unmodifiable(
         uniqueMutableFields,
       ),
       uniqueNullableMutableFields = List<ResolvedCopyWithField>.unmodifiable(
         uniqueNullableMutableFields,
       ),
       proxyMethodFields = List<ResolvedCopyWithField>.unmodifiable(
         proxyMethodFields,
       );

  /// Lightweight constructor for template-focused tests.
  factory ResolvedCopyWithSpec.testing({
    String className = 'Test',
    String typeParametersAnnotation = '',
    String typeParametersNames = '',
    String? constructorName,
    bool isPrivate = false,
    bool skipFields = false,
    bool? generatesCopyWithNull,
    List<ConstructorParameterInfo> fields = const <ConstructorParameterInfo>[],
  }) {
    final resolvedFields = fields
        .map(ResolvedCopyWithField.from)
        .toList(growable: false);
    final categorized = _CategorizedFields.from(
      resolvedFields,
      skipFields: skipFields,
    );

    return ResolvedCopyWithSpec._(
      isPrivate: isPrivate,
      className: className,
      typeParametersAnnotation: typeParametersAnnotation,
      typeParametersNames: typeParametersNames,
      constructorName: constructorName,
      skipFields: skipFields,
      generatesCopyWithNull:
          generatesCopyWithNull ??
          categorized.uniqueNullableMutableFields.isNotEmpty,
      constructorFields: resolvedFields,
      uniqueFields: categorized.uniqueFields,
      uniqueMutableFields: categorized.uniqueMutableFields,
      uniqueNullableMutableFields: categorized.uniqueNullableMutableFields,
      proxyMethodFields: categorized.proxyMethodFields,
    );
  }

  final bool isPrivate;
  final String className;
  final String typeParametersAnnotation;
  final String typeParametersNames;
  final String? constructorName;
  final bool skipFields;
  final bool generatesCopyWithNull;
  final List<ResolvedCopyWithField> constructorFields;
  final List<ResolvedCopyWithField> uniqueFields;
  final List<ResolvedCopyWithField> uniqueMutableFields;
  final List<ResolvedCopyWithField> uniqueNullableMutableFields;
  final List<ResolvedCopyWithField> proxyMethodFields;

  String get typeAnnotation => '$className$typeParametersNames';
  String get privacyPrefix => isPrivate ? '_' : '';

  /// Fully qualified constructor invocation target, e.g. `Foo<T>` for the
  /// unnamed constructor or `Foo<T>.named` for a named constructor.
  String get constructorReference =>
      constructorName == null
          ? typeAnnotation
          : '$typeAnnotation.$constructorName';

  // ── Generated type names ──────────────────────────────────────────────

  /// Bare proxy interface name without type parameters, e.g. `_$FooCWProxy`.
  /// Use for constructor declarations where type parameters are not allowed.
  String get proxyInterfaceBaseName => '_\$${className}CWProxy';

  /// Bare proxy implementation name without type parameters,
  /// e.g. `_$FooCWProxyImpl`. Use for constructor declarations.
  String get proxyImplBaseName => '_\$${className}CWProxyImpl';

  /// Abstract proxy interface declaration, e.g. `_$FooCWProxy<T extends Foo>`.
  String get proxyInterfaceName =>
      '$proxyInterfaceBaseName$typeParametersAnnotation';

  /// Concrete proxy implementation declaration,
  /// e.g. `_$FooCWProxyImpl<T extends Foo>`.
  String get proxyImplName => '$proxyImplBaseName$typeParametersAnnotation';

  /// Proxy interface reference with type argument names (no bounds),
  /// e.g. `_$FooCWProxy<T>`.
  String get proxyInterfaceRef => '$proxyInterfaceBaseName$typeParametersNames';

  /// Proxy impl reference with type argument names (no bounds),
  /// e.g. `_$FooCWProxyImpl<T>`.
  String get proxyImplRef => '$proxyImplBaseName$typeParametersNames';

  /// Extension name, e.g. `$FooCopyWith` or `_$FooCopyWith` for private
  /// classes.
  String get extensionName =>
      '$privacyPrefix\$${className}CopyWith$typeParametersAnnotation';
}

/// Pre-computed field categories derived from a flat resolved field list.
///
/// Centralizes the unique/mutable/nullable/proxy filtering so the same
/// logic is shared between [CopyWithGenerationContext.resolve] and
/// [ResolvedCopyWithSpec.testing].
class _CategorizedFields {
  const _CategorizedFields._({
    required this.uniqueFields,
    required this.uniqueMutableFields,
    required this.uniqueNullableMutableFields,
    required this.proxyMethodFields,
  });

  factory _CategorizedFields.from(
    List<ResolvedCopyWithField> resolvedFields, {
    required bool skipFields,
  }) {
    final seen = <String, ResolvedCopyWithField>{};
    for (final field in resolvedFields) {
      seen.putIfAbsent(field.name, () => field);
    }
    final uniqueFields = seen.values.toList(growable: false);
    final uniqueMutableFields = uniqueFields
        .where((field) => field.isMutable)
        .toList(growable: false);

    return _CategorizedFields._(
      uniqueFields: uniqueFields,
      uniqueMutableFields: uniqueMutableFields,
      uniqueNullableMutableFields: uniqueMutableFields
          .where((field) => field.supportsCopyWithNull)
          .toList(growable: false),
      proxyMethodFields:
          skipFields ? const <ResolvedCopyWithField>[] : uniqueMutableFields,
    );
  }

  final List<ResolvedCopyWithField> uniqueFields;
  final List<ResolvedCopyWithField> uniqueMutableFields;
  final List<ResolvedCopyWithField> uniqueNullableMutableFields;
  final List<ResolvedCopyWithField> proxyMethodFields;
}
