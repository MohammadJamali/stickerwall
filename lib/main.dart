import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stickerwall/stickerwall/stickerwall.dart';

void main() {
  runApp(const StickerWallApp());
}

class StickerWallApp extends StatelessWidget {
  const StickerWallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageBloc(context),
      child: MaterialApp(
        theme: ThemeData.light(),
        home: const StickerWall(),
      ),
    );
  }
}

class StickerWall extends StatefulWidget {
  const StickerWall({super.key});

  @override
  State<StickerWall> createState() => _StickerWallState();
}

class _StickerWallState extends State<StickerWall>
    with SingleTickerProviderStateMixin {
  Path? precomputedDotLayer;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    context.read<ImageBloc>().add(LoadImage('assets/xcode.png'));

    // AnimationController to loop animation for MaskedImagePainter
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: -0.5, 
      upperBound: 0.5,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            BlocBuilder<ImageBloc, ImageState>(
              builder: (context, state) {
                if (state is ImageLoading) {
                  return const CircularProgressIndicator();
                } else if (state is ImageLoaded) {
                  precomputedDotLayer ??= computeDotLayer(
                    randomSeed: 42,
                    dotCount: 6000,
                    minRadius: 1.0,
                    maxRadius: 4.0,
                    maskedData: state.data,
                  );

                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, _) {
                      return SizedBox(
                        width: 256,
                        height: 256,
                        child: CustomPaint(
                          painter: MaskedImagePainter(
                            maskedData: state.data,
                            precomputedDotLayer: precomputedDotLayer!,
                             animationValue: state.data.imageSize.height *_animationController.value,
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ImageError) {
                  return Text(state.message);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
