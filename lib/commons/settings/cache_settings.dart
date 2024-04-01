import 'package:meta/meta.dart';

@immutable
class GamicoCacheSettings {
  final List<String> images;

  const GamicoCacheSettings({
    required this.images,
  });
}

const defaultCacheSettings = GamicoCacheSettings(
  images: [],
);
