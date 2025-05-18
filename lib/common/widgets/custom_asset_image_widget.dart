import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final double? borderRadius;

  const CustomAssetImageWidget(this.image, {super.key, this.height, this.width, this.fit = BoxFit.cover, this.color, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isSvg = image.contains('.svg', image.length - '.svg'.length);
    
    // Widget base dependiendo si es SVG o imagen
    Widget baseWidget = isSvg 
      ? SvgPicture.asset(
          image,
          width: height, 
          height: width,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          fit: fit!,
        )
      : Image.asset(
          image, 
          fit: fit, 
          width: width, 
          height: height, 
          color: color
        );
    
    // Si hay border radius, envolver en ClipRRect
    return borderRadius != null
      ? ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius!),
          child: baseWidget,
        )
      : baseWidget;
  }
}
