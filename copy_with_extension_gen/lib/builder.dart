/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how these builders are configured by default.
library copy_with_extension_gen.builder;

import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show SharedPartBuilder;
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';

late Settings _settings;
Settings get settings => _settings;

/// Supports `package:build_runner` creation and configuration of
/// `copy_with_extension_gen`.
///
/// Not meant to be invoked by hand-authored code.
Builder copyWith(BuilderOptions config) {
  _settings = Settings.fromConfig(config.config);

  return SharedPartBuilder(
    [CopyWithGenerator()],
    'copyWith',
  );
}
