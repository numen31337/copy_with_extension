/// Global settings for the library. Allows users to globally define default values.
class Settings {
  const Settings({
    required this.copyWithNull,
    required this.skipFields,
  });

  factory Settings.fromConfig(Map json) {
    return Settings(
      copyWithNull: json['copy_with_null'] as bool? ?? false,
      skipFields: json['skip_fields'] as bool? ?? false,
    );
  }

  final bool copyWithNull;
  final bool skipFields;
}
