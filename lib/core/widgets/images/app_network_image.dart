import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../loaders/flickr_loader.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isProfile;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // Local file path (in case offline path is saved locally)
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file:')) {
      return Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // Asset paths
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const Center(child: FlickrLoader()),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          isProfile ? Icons.person : Icons.broken_image_outlined,
          color: Colors.grey[400],
          size: isProfile ? (width != null ? width! * 0.5 : 24) : 32,
        ),
      ),
    );
  }
}

class AppCachedNetworkImageProvider extends CachedNetworkImageProvider {
  AppCachedNetworkImageProvider(super.url);
}
