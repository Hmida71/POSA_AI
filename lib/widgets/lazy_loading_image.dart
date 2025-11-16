import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LazyLoadingImage extends StatefulWidget {
  final String imageUrl;
  const LazyLoadingImage({super.key, required this.imageUrl});

  @override
  State<LazyLoadingImage> createState() => _LazyLoadingImageState();
}

class _LazyLoadingImageState extends State<LazyLoadingImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.image_not_supported),
      memCacheWidth: 100, // Optimize memory cache size
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }
}
