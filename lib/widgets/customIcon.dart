// import 'package:flutter/material.dart';

// class Customicon extends StatelessWidget {
//   final String image;
//   final double? customSize;
//   const Customicon({super.key, required this.image, this.customSize});

//   @override
//   Widget build(BuildContext context) {
//     double size = customSize ?? 20;
//     return Container(
//       height: size,
//       width: size,
//       decoration:
//           BoxDecoration(image: DecorationImage(image: AssetImage(image))),
//     );
//   }
// }

import 'package:flutter/material.dart';

class Customicon extends StatelessWidget {
  final String image;
  final double? customSize;
  final Color? color;

  const Customicon({
    super.key,
    required this.image,
    this.customSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    double size = customSize ?? 20;

    return Image.asset(
      image,
      width: size,
      height: size,
      color: color, // Apply tint color
      colorBlendMode: BlendMode.srcIn, // Ensures the color applies correctly
    );
  }
}
