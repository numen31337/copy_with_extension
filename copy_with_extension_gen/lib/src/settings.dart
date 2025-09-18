/// Global settings for the library. Allows users to globally define default values.
class Settings {
  Settings({
    required this.copyWithNull,
    required this.skipFields,
    required this.immutableFields,
    Set<String>? annotations,
    this.allowNullForNonNullableFields = false,
  }) : annotations = (annotations ?? defaultAnnotations)
            .map((e) => e.toLowerCase())
            .toSet();

  /// Creates [Settings] from a configuration map, typically coming from
  /// a `build.yaml` file.
  factory Settings.fromConfig(Map<String, dynamic> json) {
    Set<String>? rawAnnotations;
    if (json.containsKey('annotations')) {
      rawAnnotations = (json['annotations'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toSet();
    }

    return Settings(
      copyWithNull: json['copy_with_null'] as bool? ?? false,
      skipFields: json['skip_fields'] as bool? ?? false,
      immutableFields: json['immutable_fields'] as bool? ?? false,
      allowNullForNonNullableFields:
          json['allow_null_for_non_nullable_fields'] as bool? ?? false,
      annotations: rawAnnotations,
    );
  }

  final bool copyWithNull;
  final bool skipFields;
  final bool immutableFields;
  final Set<String> annotations;
  final bool allowNullForNonNullableFields;

  /// Default annotation names forwarded to generated parameters.
  static const defaultAnnotations = {'Deprecated'};
}
