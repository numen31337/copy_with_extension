import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader;

/// Utilities for reading annotation values.
class AnnotationUtils {
  const AnnotationUtils._();

  /// Restores the `CopyWith` annotation provided by the user.
  static CopyWithAnnotation readClassAnnotation(
    Settings settings,
    ConstantReader reader,
  ) {
    final generateCopyWithNull = reader.peek('copyWithNull')?.boolValue;
    final skipFields = reader.peek('skipFields')?.boolValue;
    final constructor = reader.peek('constructor')?.stringValue;

    return CopyWithAnnotation(
      copyWithNull: generateCopyWithNull ?? settings.copyWithNull,
      skipFields: skipFields ?? settings.skipFields,
      constructor: constructor,
    );
  }
}
