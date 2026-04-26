import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

import 'copy_with_null_template.dart';
import 'proxy_template.dart';

/// Builds the entire extension code snippet.
/// This method assembles the proxy class and the extension declaration that is added to the generated file.
String extensionTemplate(ResolvedCopyWithSpec spec) {
  final proxy = copyWithProxyTemplate(spec);
  final copyWithNullBlock =
      spec.generatesCopyWithNull ? copyWithNullTemplate(spec) : '';

  return '''
    $proxy

    extension ${spec.extensionName} on ${spec.typeAnnotation} {
      /// Returns a callable class used to build a new instance with modified fields.
      /// Example: `instanceOf${spec.className}.copyWith(...)`${spec.skipFields ? "" : " or `instanceOf${spec.className}.copyWith.fieldName(...)`"}.
      // ignore: library_private_types_in_public_api
      ${spec.proxyInterfaceRef} get copyWith => ${spec.proxyImplRef}(this);

      $copyWithNullBlock
    }
    ''';
}
