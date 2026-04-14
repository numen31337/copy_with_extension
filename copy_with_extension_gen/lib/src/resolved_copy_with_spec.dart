// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement;
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/field_resolution_config.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;

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

  /// Resolves constructor, inheritance, and per-field generation behavior into
  /// a single spec consumed by the templates.
  Future<ResolvedCopyWithSpec> resolve() async {
    var superInfo = _findSuperInfo();
    final result = await ConstructorUtils.constructorFields(
      classElement,
      annotation.constructor,
      FieldResolutionConfig(
        annotations: settings.annotations,
        immutableDefault: annotation.immutableFields,
        annotatedSuper: superInfo?.element,
      ),
    );
    final fields = result.fields;
    superInfo = await _validateSuperFields(superInfo, fields);
    _validateFieldNullability(fields);

    final shouldExtendSuperProxy =
        superInfo != null &&
        superInfo.element.library == superInfo.originLibrary;
    final resolvedFields = fields
        .map(
          (field) => ResolvedCopyWithField(
            parameter: field,
            delegatesToSuper:
                shouldExtendSuperProxy &&
                field.isInherited &&
                hasNonSkippedFieldProxy(field.classField, settings),
          ),
        )
        .toList(growable: false);
    final categorized = _CategorizedFields.from(
      resolvedFields,
      skipFields: annotation.skipFields,
    );

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
      generatesCopyWithNull:
          annotation.copyWithNull ||
          (superInfo?.copyWithNull == true &&
              categorized.uniqueNullableMutableFields.isNotEmpty),
      superInfo: superInfo,
      shouldExtendSuperProxy: shouldExtendSuperProxy,
      constructorFields: resolvedFields,
      uniqueFields: categorized.uniqueFields,
      uniqueMutableFields: categorized.uniqueMutableFields,
      uniqueNullableMutableFields: categorized.uniqueNullableMutableFields,
      proxyMethodFields: categorized.proxyMethodFields,
    );
  }

  AnnotatedCopyWithSuper? _findSuperInfo() {
    var superInfo = findAnnotatedSuper(classElement, settings);
    if (annotation.skipFields &&
        superInfo != null &&
        classElement.supertype?.element != superInfo.element) {
      superInfo = null;
    }
    return superInfo;
  }

  Future<AnnotatedCopyWithSuper?> _validateSuperFields(
    AnnotatedCopyWithSuper? superInfo,
    List<ConstructorParameterInfo> fields,
  ) async {
    if (superInfo != null) {
      final superResult = await ConstructorUtils.constructorFields(
        superInfo.element,
        superInfo.constructor,
        FieldResolutionConfig(
          annotations: settings.annotations,
          immutableDefault: superInfo.immutableFields,
        ),
      );
      final superFields = superResult.fields
          .where((field) => !field.fieldAnnotation.immutable)
          .map((field) => field.name)
          .toSet();
      final fieldNames = fields.map((field) => field.name).toSet();
      if (!fieldNames.containsAll(superFields)) {
        return null;
      }
    }
    return superInfo;
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
class ResolvedCopyWithField {
  const ResolvedCopyWithField({
    required this.parameter,
    required this.delegatesToSuper,
  });

  final ConstructorParameterInfo parameter;
  final bool delegatesToSuper;

  // ── Properties used by templates ──────────────────────────────────────

  String get name => parameter.name;
  bool get nullable => parameter.nullable;
  String get type => parameter.type;
  bool get isMutable => !parameter.fieldAnnotation.immutable;
  bool get supportsCopyWithNull => nullable && isMutable;

  /// The conditional expression that tests whether the parameter was
  /// explicitly supplied by the caller. Non-nullable fields include an
  /// additional `|| $name == null` guard so that passing `null` for a
  /// non-nullable parameter is treated as "not supplied".
  String get placeholderCheckExpression => nullable
      ? '$name == const \$CopyWithPlaceholder()'
      : '$name == const \$CopyWithPlaceholder() || $name == null';

  /// Metadata annotations formatted as a prefix for generated parameters.
  /// Returns an empty string when there are no annotations.
  String get annotationPrefix {
    final m = parameter.metadata;
    return m.isEmpty ? '' : '${m.join(' ')} ';
  }

  /// Constructor argument prefix for named parameters (e.g. `fieldName: `),
  /// empty for positional parameters.
  String get constructorArgPrefix =>
      parameter.isPositioned ? '' : '${parameter.constructorParamName}: ';

  // ── Properties used during resolution ─────────────────────────────────

  FieldElement? get classField => parameter.classField;
  bool get isInherited => parameter.isInherited;
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
    required this.superInfo,
    required this.shouldExtendSuperProxy,
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
    Set<String> delegatedFieldNames = const <String>{},
  }) {
    final resolvedFields = fields
        .map(
          (field) => ResolvedCopyWithField(
            parameter: field,
            delegatesToSuper: delegatedFieldNames.contains(field.name),
          ),
        )
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
      superInfo: null,
      shouldExtendSuperProxy: delegatedFieldNames.isNotEmpty,
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
  final AnnotatedCopyWithSuper? superInfo;
  final bool shouldExtendSuperProxy;
  final List<ResolvedCopyWithField> constructorFields;
  final List<ResolvedCopyWithField> uniqueFields;
  final List<ResolvedCopyWithField> uniqueMutableFields;
  final List<ResolvedCopyWithField> uniqueNullableMutableFields;
  final List<ResolvedCopyWithField> proxyMethodFields;

  String get typeAnnotation => '$className$typeParametersNames';
  String get privacyPrefix => isPrivate ? '_' : '';

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
      '${privacyPrefix}\$${className}CopyWith$typeParametersAnnotation';

  // ── Inheritance clauses ───────────────────────────────────────────────

  String get proxyExtendsClause => _superExtendsClause('CWProxy');
  String get proxyImplExtendsClause => _superExtendsClause('CWProxyImpl');

  String _superExtendsClause(String suffix) {
    final superInfo = this.superInfo;
    if (!shouldExtendSuperProxy || superInfo == null) {
      return '';
    }
    return ' extends ${superInfo.prefix}_\$${superInfo.name}$suffix'
        '${superInfo.typeArgumentsAnnotation()}';
  }
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
      proxyMethodFields: uniqueMutableFields
          .where((field) => !skipFields || field.delegatesToSuper)
          .toList(growable: false),
    );
  }

  final List<ResolvedCopyWithField> uniqueFields;
  final List<ResolvedCopyWithField> uniqueMutableFields;
  final List<ResolvedCopyWithField> uniqueNullableMutableFields;
  final List<ResolvedCopyWithField> proxyMethodFields;
}
