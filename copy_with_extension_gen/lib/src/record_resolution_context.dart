// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart' show Token;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';
import 'package:source_gen/source_gen.dart';

/// Resolves only immediate components of an explicitly annotated record alias.
class RecordResolutionContext {
  RecordResolutionContext(this.alias, this.annotation, this.buildStep);

  final TypeAliasElement alias;
  final CopyWithAnnotation annotation;
  final BuildStep buildStep;
  final _visible = <Element, List<String>>{};
  final _conditional = <LibraryElement, Set<int>>{};

  LibraryElement get library => alias.library;

  Future<ResolvedCopyWithSpec> resolve() async {
    if (annotation.constructor != null) {
      _fail(
        'Record "${alias.name}" has no constructor; remove `constructor:`.',
      );
    }
    final declaration = await buildStep.resolver.astNodeFor(
      alias.firstFragment,
      resolve: true,
    );
    if (declaration is! GenericTypeAlias) {
      _fail(
        'Cannot resolve the declaration syntax for record "${alias.name}".',
      );
    }
    final syntax = declaration.type;
    final type = alias.aliasedType;
    if (syntax is! RecordTypeAnnotation || type is! RecordType) {
      _fail(
        '@CopyWith requires a direct record typedef right-hand side; '
        'alias chains and non-record typedefs are unsupported.',
        syntax,
      );
    }
    if (type.nullabilitySuffix != NullabilitySuffix.none) {
      _fail(
        'Nullable record typedef roots are unsupported; remove the root `?`.',
        syntax,
      );
    }

    final components = <(String, DartType, bool, RecordTypeAnnotationField)>[];
    if (syntax.positionalFields.length != type.positionalFields.length) {
      _fail(
        'Cannot map positional record components without losing metadata.',
        syntax,
      );
    }
    for (var i = 0; i < type.positionalFields.length; i++) {
      components.add((
        '\$${i + 1}',
        type.positionalFields[i].type,
        true,
        syntax.positionalFields[i],
      ));
    }
    final named = {
      for (final field
          in syntax.namedFields?.fields ?? <RecordTypeAnnotationNamedField>[])
        field.name.lexeme: field,
    };
    if (named.length != type.namedFields.length) {
      _fail(
        'Cannot map named record components without losing metadata.',
        syntax,
      );
    }
    for (final field in type.namedFields) {
      final node = named[field.name];
      if (node == null) {
        _fail('Cannot map record component "${field.name}".', syntax);
      }
      components.add((field.name, field.type, false, node));
    }
    for (final (name, fieldType, _, node) in components) {
      if (node.metadata.isNotEmpty) {
        _fail(
          'Metadata on record component "$name" is unsupported; remove the component annotation.',
          node.metadata.first,
        );
      }
      if (fieldType is VoidType) {
        _fail(
          'Immediate void-typed record component "$name" is unsupported.',
          node,
        );
      }
    }

    final mutableNames =
        annotation.immutableFields
            ? <String>{}
            : components.map((field) => field.$1).toSet();
    if (!annotation.skipFields && mutableNames.contains('call')) {
      _fail(
        'Record component "call" conflicts with the callable proxy; use `skipFields: true`.',
        components.firstWhere((field) => field.$1 == 'call').$4,
      );
    }
    final memberNames = <String>{
      'call',
      '_value',
      if (!annotation.skipFields) ...mutableNames,
    };
    final hasClearFlags =
        annotation.copyWithNull &&
        mutableNames.isNotEmpty &&
        components.any((field) => library.typeSystem.isNullable(field.$2));
    final boundShadows = {
      ...memberNames,
      'copyWith',
      if (hasClearFlags) 'copyWithNull',
    };
    for (final parameter in alias.typeParameters) {
      if (boundShadows.contains(parameter.name) ||
          parameter.name == alias.name) {
        _fail(
          'Record type parameter "${parameter.name}" conflicts with a generated member; rename the source type parameter.',
        );
      }
    }
    if (memberNames.contains(alias.name) ||
        hasClearFlags &&
            const {'copyWith', 'copyWithNull'}.contains(alias.name)) {
      _fail(
        'Record alias "${alias.name}" is shadowed by a generated member; rename the alias or component, or use `skipFields: true` for a component-method conflict.',
      );
    }

    final required = <Element>{};
    String collect(String name, Element? element, Set<String> localParameters) {
      if (element != null) required.add(element);
      return name;
    }

    for (final (_, fieldType, _, _) in components) {
      if (!annotation.immutableFields) {
        ElementUtils.typeNameWithPrefix(library, fieldType, reference: collect);
      }
    }
    ElementUtils.typeParametersString(alias, false, reference: collect);
    final objectElement = library.typeProvider.objectElement;
    final boolElement = library.typeProvider.boolType.element;
    final overrideElement =
        objectElement.library.getTopLevelVariable('override')!.getter!;
    required.add(overrideElement);
    if (mutableNames.isNotEmpty) required.add(objectElement);
    if (hasClearFlags) required.add(boolElement);
    ClassElement? placeholder;
    if (mutableNames.isNotEmpty) {
      final annotations = await buildStep.resolver.libraryFor(
        AssetId('copy_with_extension', 'lib/copy_with_extension.dart'),
      );
      placeholder = annotations.getClass(r'$CopyWithPlaceholder');
      if (placeholder == null) {
        _fail('Cannot resolve the copy-with omission placeholder.');
      }
      required.add(placeholder);
    }
    for (final element in required) {
      _visible[element] = await _visibleNames(element);
    }
    final declarationShadows = memberNames;
    final argumentShadows = {...declarationShadows, ...mutableNames};
    final inputType =
        mutableNames.isEmpty
            ? 'Object?'
            : '${_reference(objectElement, declarationShadows, syntax)}?';
    final clearFlagType =
        hasClearFlags
            ? _reference(boolElement, {'copyWith', 'copyWithNull'}, syntax)
            : 'bool';
    final placeholderName =
        placeholder == null
            ? r'$CopyWithPlaceholder'
            : _reference(placeholder, argumentShadows, syntax);
    final fields = <ResolvedCopyWithField>[];
    for (final (name, fieldType, positioned, node) in components) {
      fields.add(
        ResolvedCopyWithField.record(
          name: name,
          type:
              annotation.immutableFields
                  ? fieldType.getDisplayString()
                  : ElementUtils.typeNameWithPrefix(
                    library,
                    fieldType,
                    reference:
                        (name, element, localParameters) => _reference(
                          element,
                          {...argumentShadows, ...localParameters},
                          node,
                          name: name,
                        ),
                  ),
          nullable: library.typeSystem.isNullable(fieldType),
          isMutable: !annotation.immutableFields,
          isPositioned: positioned,
          placeholderType: placeholderName,
          inputType: inputType,
          requiresCast:
              !library.typeSystem.isSubtypeOf(
                library.typeProvider.objectQuestionType,
                fieldType,
              ),
        ),
      );
    }
    final spec = ResolvedCopyWithSpec.record(
      name: alias.displayName,
      isPrivate: alias.isPrivate,
      typeParametersAnnotation: ElementUtils.typeParametersString(
        alias,
        false,
        reference:
            (name, element, localParameters) => _reference(
              element,
              {...boundShadows, ...localParameters},
              syntax,
              name: name,
            ),
      ),
      typeParametersNames: ElementUtils.typeParametersString(alias, true),
      annotation: annotation,
      fields: fields,
      clearFlagType: clearFlagType,
      overrideAnnotation: _reference(
        overrideElement,
        declarationShadows,
        syntax,
      ),
    );
    await _validateGeneratedNames(spec);
    return spec;
  }

  String _reference(
    Element? element,
    Set<String> shadows,
    AstNode node, {
    String? name,
  }) {
    name ??= element!.displayName;
    if (element == null) {
      if (!shadows.contains(name)) return name;
    } else if (element is TypeParameterElement) {
      // Function-type binders own their inner scope independently of call args.
      if (!alias.typeParameters.contains(element) || !shadows.contains(name)) {
        return name;
      }
    } else {
      for (final spelling in _visible[element] ?? const <String>[]) {
        final first = spelling.split('.').first;
        if (!shadows.contains(first) &&
            !alias.typeParameters.any((parameter) => parameter.name == first)) {
          return spelling;
        }
      }
    }
    _fail(
      'Record component scope cannot reference "$name" without shadowing or an unsupported import. Rename the source type parameter/import prefix/component, or expose an unambiguous unconditional non-deferred import for "$name".',
      node,
    );
  }

  Future<List<String>> _visibleNames(Element element) async {
    if (element is TypeParameterElement || element.library == library) {
      return [element.displayName];
    }
    final name = element.displayName;
    final result = <String>[];
    for (final import in library.firstFragment.libraryImports) {
      if (import.namespace.definedNames2[name] != element ||
          import.prefix?.isDeferred == true) {
        continue;
      }
      if ((await _conditionalOffsets(
        library,
      )).contains(import.importKeywordOffset)) {
        continue;
      }
      final imported = import.importedLibrary;
      if (imported == null ||
          !await _hasUnconditionalRoute(imported, element, {})) {
        continue;
      }
      final prefix = import.prefix?.element;
      if (prefix == null) {
        final local = library.children.where((child) => child.name == name);
        if (local.any((child) => child != element)) continue;
        if (library.firstFragment.libraryImports.any(
          (other) =>
              other.prefix == null &&
              other.namespace.definedNames2[name] != null &&
              other.namespace.definedNames2[name] != element,
        )) {
          continue;
        }
        result.add(name);
      } else {
        if (prefix.imports.any(
          (other) =>
              other.namespace.definedNames2[name] != null &&
              other.namespace.definedNames2[name] != element,
        )) {
          continue;
        }
        result.add('${prefix.name}.$name');
      }
    }
    final current =
        '${ElementUtils.libraryImportPrefix(library, element.library)}$name';
    return [
      if (result.contains(current)) current,
      ...result.where((name) => name != current),
    ];
  }

  Future<bool> _hasUnconditionalRoute(
    LibraryElement from,
    Element target,
    Set<LibraryElement> visited,
  ) async {
    if (from == target.library) return true;
    if (!visited.add(from)) return false;
    final name = target.displayName;
    for (final export in from.firstFragment.libraryExports) {
      final next = export.exportedLibrary;
      if (next == null ||
          next.exportNamespace.definedNames2[name] != target ||
          !_admits(export.combinators, name) ||
          (await _conditionalOffsets(
            from,
          )).contains(export.exportKeywordOffset)) {
        continue;
      }
      if (await _hasUnconditionalRoute(next, target, {...visited})) return true;
    }
    return false;
  }

  bool _admits(List<NamespaceCombinator> combinators, String name) =>
      combinators.every(
        (combinator) =>
            combinator is ShowElementCombinator
                ? combinator.shownNames.contains(name)
                : combinator is! HideElementCombinator ||
                    !combinator.hiddenNames.contains(name),
      );

  Future<Set<int>> _conditionalOffsets(LibraryElement element) async {
    if (_conditional.containsKey(element)) return _conditional[element]!;
    if (element.uri.scheme == 'dart') return _conditional[element] = {};
    final asset = await buildStep.resolver.assetIdForElement(element);
    final unit = await buildStep.resolver.compilationUnitFor(asset);
    return _conditional[element] = {
      for (final directive in unit.directives)
        if (directive is ImportDirective && directive.configurations.isNotEmpty)
          directive.importKeyword.offset,
      for (final directive in unit.directives)
        if (directive is ExportDirective && directive.configurations.isNotEmpty)
          directive.exportKeyword.offset,
    };
  }

  Future<void> _validateGeneratedNames(ResolvedCopyWithSpec spec) async {
    final names = {
      spec.proxyInterfaceBaseName,
      spec.proxyImplBaseName,
      '${spec.privacyPrefix}\$${alias.displayName}CopyWith',
    };
    for (final parameter in alias.typeParameters) {
      if (names.contains(parameter.name)) {
        _fail(
          'Record type parameter "${parameter.name}" conflicts with a generated declaration; rename the source type parameter.',
        );
      }
    }
    for (final prefix in library.firstFragment.prefixes) {
      if (names.contains(prefix.name)) {
        throw InvalidGenerationSourceError(
          'Generated record declaration "${prefix.name}" conflicts with an import prefix. Rename the prefix.',
          element: prefix,
        );
      }
    }
    for (final import in library.firstFragment.libraryImports) {
      if (import.prefix != null) continue;
      for (final name in names) {
        final imported = import.namespace.definedNames2[name];
        if (imported != null && imported.library != library) {
          _fail(
            'Generated record declaration "$name" conflicts with an unprefixed imported declaration. Use a prefixed import or hide that declaration.',
          );
        }
      }
    }
    for (final element in library.children) {
      if (!names.contains(element.name)) continue;
      final node = await buildStep.resolver.astNodeFor(element.firstFragment);
      Token? comment = node?.beginToken.precedingComments;
      var owned = false;
      while (comment != null) {
        if (comment.lexeme ==
            '// copy_with_extension_gen: record ${alias.displayName}') {
          owned = true;
        }
        comment = comment.next;
      }
      if (!owned) {
        throw InvalidGenerationSourceError(
          'Generated record declaration "${element.name}" conflicts with an existing declaration. Rename that declaration.',
          element: element,
        );
      }
    }
  }

  Never _fail(String message, [AstNode? node]) =>
      throw InvalidGenerationSourceError(
        message,
        node: node,
        element: node == null ? alias : null,
      );
}
