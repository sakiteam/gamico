import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GamicoImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const GamicoImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize =
        min(40, (min(width ?? 40, height ?? 40) * 24 / 40).toDouble());

    return (path.contains("http")
        ? CachedNetworkImage(
            imageUrl: path,
            width: width,
            height: height,
            fit: fit,
            progressIndicatorBuilder: (_, __, ___) {
              return Center(
                child: SizedBox(
                  width: circleSize <= 40 ? 24.0 : circleSize,
                  height: circleSize <= 40 ? 24.0 : circleSize,
                  child: CircularProgressIndicator(
                    strokeWidth: circleSize <= 40 ? 2.0 : 4.0,
                  ),
                ),
              );
            },
            errorWidget: (_, __, ___) {
              return const Icon(Icons.image_not_supported);
            },
          )
        : (path.contains("assets/images/")
            ? (path.endsWith("svg")
                ? SvgPicture.asset(
                    path,
                    width: width,
                    height: height,
                    fit: fit ?? BoxFit.contain,
                  )
                : Image.asset(
                    path,
                    width: width,
                    height: height,
                    fit: fit,
                  ))
            : Image.file(
                File(path),
                width: width,
                height: height,
                fit: fit,
              )));
  }
}
