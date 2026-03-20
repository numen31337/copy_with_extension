import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show SharedPartBuilder;

/// Supports `package:build_runner` creation and configuration of
/// `copy_with_extension_gen`.
///
/// Not meant to be invoked by hand-authored code.
Builder copyWith(BuilderOptions config) {
  return SharedPartBuilder([
    CopyWithGenerator(Settings.fromConfig(config.config)),
  ], 'copyWith');
}
