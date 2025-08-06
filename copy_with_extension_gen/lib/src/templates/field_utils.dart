import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';

/// Returns a list of unique fields by name.
///
/// When multiple fields share the same name, only the first occurrence is kept.
List<ConstructorParameterInfo> uniqueConstructorFields(
  Iterable<ConstructorParameterInfo> fields,
) {
  final map = <String, ConstructorParameterInfo>{};
  for (final field in fields) {
    map.putIfAbsent(field.name, () => field);
  }
  return map.values.toList();
}
