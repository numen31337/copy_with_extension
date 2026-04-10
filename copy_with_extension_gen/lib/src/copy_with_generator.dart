// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart' show ClassElement, Element;
import 'package:build/build.dart' show BuildStep;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
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
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final classElement = _expectClassElement(element);
    final classAnnotation = AnnotationUtils.readClassAnnotation(
      settings,
      annotation,
    );
    final spec =
        CopyWithGenerationContext(
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
      'The @CopyWith annotation is only supported on classes. "$element" is not a class.',
      element: element,
    );
  }
}
