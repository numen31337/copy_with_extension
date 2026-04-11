// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement, FieldElement;
import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
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
    final fields = await ConstructorUtils.constructorFields(
      classElement,
      annotation.constructor,
      annotatedSuper: superInfo?.element,
      annotations: settings.annotations,
      immutableFields: annotation.immutableFields,
    );
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
    final uniqueFields = _uniqueFields(resolvedFields);
    final uniqueMutableFields = uniqueFields
        .where((field) => field.isMutable)
        .toList(growable: false);
    final uniqueNullableMutableFields = uniqueMutableFields
        .where((field) => field.supportsCopyWithNull)
        .toList(growable: false);
    final proxyMethodFields = uniqueMutableFields
        .where((field) => !annotation.skipFields || field.delegatesToSuper)
        .toList(growable: false);

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
      constructorName: _resolveConstructorName(),
      skipFields: annotation.skipFields,
      generatesCopyWithNull:
          annotation.copyWithNull ||
          (superInfo?.copyWithNull == true &&
              uniqueNullableMutableFields.isNotEmpty),
      superInfo: superInfo,
      shouldExtendSuperProxy: shouldExtendSuperProxy,
      constructorFields: resolvedFields,
      uniqueFields: uniqueFields,
      uniqueMutableFields: uniqueMutableFields,
      uniqueNullableMutableFields: uniqueNullableMutableFields,
      proxyMethodFields: proxyMethodFields,
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
      final resolvedSuperFields = await ConstructorUtils.constructorFields(
        superInfo.element,
        superInfo.constructor,
        annotations: settings.annotations,
        immutableFields: superInfo.immutableFields,
      );
      final superFields =
          resolvedSuperFields
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

  String? _resolveConstructorName() {
    final targetConstructor =
        annotation.constructor != null
            ? classElement.getNamedConstructor(annotation.constructor!)
            : classElement.unnamedConstructor;
    if (targetConstructor is! ConstructorElement) {
      return annotation.constructor;
    }

    final resolved = ConstructorUtils.resolveRedirects(
      classElement,
      targetConstructor,
    );
    final name = resolved.name;
    return name == 'new' ? null : name;
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

  String get constructorParamName => parameter.constructorParamName;
  String get name => parameter.name;
  bool get nullable => parameter.nullable;
  String get type => parameter.type;
  bool get isPositioned => parameter.isPositioned;
  List<String> get metadata => parameter.metadata;
  FieldElement? get classField => parameter.classField;
  bool get isInherited => parameter.isInherited;
  bool get isMutable => !parameter.fieldAnnotation.immutable;
  bool get supportsCopyWithNull => nullable && isMutable;
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
    final uniqueFields = _uniqueFields(resolvedFields);
    final uniqueMutableFields = uniqueFields
        .where((field) => field.isMutable)
        .toList(growable: false);
    final uniqueNullableMutableFields = uniqueMutableFields
        .where((field) => field.supportsCopyWithNull)
        .toList(growable: false);

    return ResolvedCopyWithSpec._(
      isPrivate: isPrivate,
      className: className,
      typeParametersAnnotation: typeParametersAnnotation,
      typeParametersNames: typeParametersNames,
      constructorName: constructorName,
      skipFields: skipFields,
      generatesCopyWithNull:
          generatesCopyWithNull ?? uniqueNullableMutableFields.isNotEmpty,
      superInfo: null,
      shouldExtendSuperProxy: delegatedFieldNames.isNotEmpty,
      constructorFields: resolvedFields,
      uniqueFields: uniqueFields,
      uniqueMutableFields: uniqueMutableFields,
      uniqueNullableMutableFields: uniqueNullableMutableFields,
      proxyMethodFields: uniqueMutableFields
          .where((field) => !skipFields || field.delegatesToSuper)
          .toList(growable: false),
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

  String get proxyExtendsClause {
    final superInfo = this.superInfo;
    if (!shouldExtendSuperProxy || superInfo == null) {
      return '';
    }
    return ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxy'
        '${superInfo.typeArgumentsAnnotation()}';
  }

  String get proxyImplExtendsClause {
    final superInfo = this.superInfo;
    if (!shouldExtendSuperProxy || superInfo == null) {
      return '';
    }
    return ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxyImpl'
        '${superInfo.typeArgumentsAnnotation()}';
  }
}

List<ResolvedCopyWithField> _uniqueFields(
  Iterable<ResolvedCopyWithField> fields,
) {
  final uniqueFields = <String, ResolvedCopyWithField>{};
  for (final field in fields) {
    uniqueFields.putIfAbsent(field.name, () => field);
  }
  return uniqueFields.values.toList(growable: false);
}
