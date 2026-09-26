// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart'
    show ClassElement, Element, TypeAliasElement;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/record_resolution_context.dart';
import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:copy_with_extension_gen/src/templates/extension_template.dart';
import 'package:source_gen/source_gen.dart'
    show ConstantReader, GeneratorForAnnotation, InvalidGenerationSourceError;

/// Builds `copyWith` extensions for classes annotated with `@CopyWith`.
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  CopyWithGenerator(this.settings) : super();

  final Settings settings;

  /// Generates the `copyWith` extension code for the annotated [element].
  ///
  /// The method validates the target class, gathers all constructor
  /// parameters and user provided settings, and returns the source code for
  /// the extension as a string.
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final classAnnotation = AnnotationUtils.readClassAnnotation(
      settings,
      annotation,
    );
    if (element is TypeAliasElement) {
      return extensionTemplate(
        await RecordResolutionContext(
          element,
          classAnnotation,
          buildStep,
        ).resolve(),
      );
    }
    final classElement = _expectClassElement(element);
    final spec =
        await CopyWithGenerationContext(
          classElement: classElement,
          annotation: classAnnotation,
          settings: settings,
        ).resolve();

    return extensionTemplate(spec);
  }

  ClassElement _expectClassElement(Element element) {
    if (element is ClassElement) {
      return element;
    }
    throw InvalidGenerationSourceError(
      'The @CopyWith annotation is only supported on classes or direct record typedefs. "$element" is not a supported target.',
      element: element,
    );
  }
}
