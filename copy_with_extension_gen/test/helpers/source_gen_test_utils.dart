import 'dart:io';

import 'package:source_gen/source_gen.dart' show LibraryReader;
import 'package:source_gen_test/source_gen_test.dart'
    show initializeLibraryReaderForDirectory;

const _packageName = 'copy_with_extension_gen';

/// Resolves a package-local [path] against the generator package root.
///
/// Tests in this package are commonly run from either `copy_with_extension_gen`
/// or the workspace root. Keeping path resolution here prevents source-gen
/// fixtures and goldens from depending on the process working directory.
String resolvePackagePath(String path) {
  if (_isAbsolutePath(path)) {
    return path;
  }

  return _joinPath(_packageRoot.path, path);
}

Future<LibraryReader> initializePackageLibraryReaderForDirectory(
  String sourceDirectory,
  String targetLibraryFileName,
) {
  return initializeLibraryReaderForDirectory(
    resolvePackagePath(sourceDirectory),
    targetLibraryFileName,
  );
}

Directory? _cachedPackageRoot;

Directory get _packageRoot {
  return _cachedPackageRoot ??= _findPackageRoot();
}

Directory _findPackageRoot() {
  var directory = Directory.current.absolute;

  while (true) {
    for (final candidate in <Directory>[
      directory,
      Directory(_joinPath(directory.path, _packageName)),
    ]) {
      if (_isPackageRoot(candidate)) {
        return candidate.absolute;
      }
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      break;
    }
    directory = parent;
  }

  throw StateError(
    'Could not locate the $_packageName package root from '
    '${Directory.current.path}.',
  );
}

bool _isPackageRoot(Directory directory) {
  final pubspec = File(_joinPath(directory.path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return false;
  }

  return pubspec.readAsLinesSync().any(
    (line) => line.trim() == 'name: $_packageName',
  );
}

bool _isAbsolutePath(String path) {
  if (path.startsWith('/')) {
    return true;
  }

  if (!Platform.isWindows) {
    return false;
  }

  return path.startsWith(r'\\') || RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path);
}

String _joinPath(String parent, String child) {
  final normalizedChild = child.replaceAll('/', Platform.pathSeparator);
  if (normalizedChild.isEmpty) {
    return parent;
  }

  if (parent.endsWith(Platform.pathSeparator)) {
    return '$parent$normalizedChild';
  }

  return '$parent${Platform.pathSeparator}$normalizedChild';
}
