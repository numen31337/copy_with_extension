import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:source_gen/source_gen.dart' show SharedPartBuilder;
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';

Builder copyWith(BuilderOptions _) => SharedPartBuilder(
      [CopyWithGenerator()],
      'copyWith',
    );
