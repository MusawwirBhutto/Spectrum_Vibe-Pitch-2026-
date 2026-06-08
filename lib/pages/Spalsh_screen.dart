import 'dart:ui' as ui;
import 'package:baalkatwao/pages/MainNavigationPage.dart';
import 'package:baalkatwao/pages/role_selection_page.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Make sure this import is here

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // controller drives the whole choreography
  late final AnimationController _controller;

  // assets
  final String appIconAsset = 'assets/images/logo.png';
  final String logoTextAsset = 'assets/images/Groomin_final.png';

  // sizes
  static const double _iconStartSize = 220.0; // initial central icon size
  static const double _iconEndSize = 15.0; // final "dot-like" size on the 'i'

  // --- SIZE FIX ---
  // We removed the fixed _groomTargetWidth. The size will now be
  // calculated based on the screen width in the 'build' method.

  // layout keys and measured values
  final GlobalKey _groomKey = GlobalKey();
  Rect? _groomRect; // measured rect of groom image in global coordinates

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Precache images
      try {
        await Future.wait([
          precacheImage(AssetImage(appIconAsset), context),
          precacheImage(AssetImage(logoTextAsset), context),
        ]);
      } catch (_) {}

      // measure groom image rect
      _captureGroomRect();

      // small delay so user sees initial centered icon for a moment
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      // start animation
      _controller.forward();

      // when finished navigate
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const RoleSelectionPage()),
            );
          });
        }
      });
    });
  }

  void _captureGroomRect() {
    try {
      final RenderBox? box =
          _groomKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final Offset topLeft = box.localToGlobal(Offset.zero);
        _groomRect = topLeft & box.size;
      }
    } catch (_) {
      _groomRect = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // helper lerp
  double _lerpDouble(double a, double b, double t) =>
      ui.lerpDouble(a, b, t) ?? a;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    // --- FIX FOR LOGO SIZE (PROBLEM 1) ---
    // We now base the logo width on the phone's screen.
    // 80% is a good large size. You can change 0.8 to 0.7 or 0.9 to test.
    final double groomWidth = screen.width * 0.9;
    // --- END OF FIX ---

    // This aspect ratio was in your code. If the logo looks stretched, change 0.36
    final double groomHeight = groomWidth * 0.8;
    final double groomLeft = (screen.width - groomWidth) / 2;
    final double groomTop = (screen.height - groomHeight) / 2;

    // icon start (center)
    final double iconStartSize = _iconStartSize;
    final double iconStartLeft = (screen.width - iconStartSize) / 2;
    final double iconStartTop = (screen.height - iconStartSize) / 2;

    // --- FIX FOR DOT POSITION (PROBLEM 2) ---
    // These are your "tuning knobs." Change these two numbers
    // and hot-reload to see the dot move.

    // 0.72 = 72% from the left edge of the logo.
    // Make this number SMALLER to move the dot LEFT.
    // Make this number LARGER to move the dot RIGHT.
    final double dotRelXFraction = 0.66;

    // 0.18 = 18% from the top edge of the logo.
    // Make this number SMALLER to move the dot UP.
    // Make this number LARGER to move the dot DOWN.
    final double dotRelYFraction = 0.36;
    // --- END OF FIX ---

    // If we measured the groom rect on screen, use that; otherwise use groomLeft/top estimates
    final double groomActualLeft =
        _groomRect?.left ?? groomLeft; // global coordinate
    final double groomActualTop = _groomRect?.top ?? groomTop;
    final double groomActualWidth = _groomRect?.width ?? groomWidth;
    final double groomActualHeight = _groomRect?.height ?? groomHeight;

    final double iconEndSize = _iconEndSize;

    // final target center point for the icon (to sit as the 'i' dot)
    final double iconTargetCenterX =
        groomActualLeft + groomActualWidth * dotRelXFraction;
    final double iconTargetCenterY =
        groomActualTop + groomActualHeight * dotRelYFraction;

    // compute end left/top from center
    final double iconEndLeft = iconTargetCenterX - (iconEndSize / 2);
    final double iconEndTop = iconTargetCenterY - (iconEndSize / 2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // also try to recapture groomRect each frame for more accurate target (if available)
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _captureGroomRect(),
          );

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // groom opacity: fade in quickly early so text is clear by the time icon shrinks
              final double groomOpacity = (_controller.value < 0.12)
                  ? (_controller.value / 0.12)
                  : 1.0;

              // icon size interpolation (stay big initially, then shrink mostly between 0.35..0.95)
              final double sizeT = Curves.easeInOut.transform(
                ((_controller.value - 0.18) / 0.78).clamp(0.0, 1.0),
              );
              final double iconSize = _lerpDouble(
                iconStartSize,
                iconEndSize,
                sizeT,
              );

              // icon position interpolation: move from center to iconEndLeft/top along eased path
              final double posT = Curves.easeInOut.transform(
                ((_controller.value - 0.18) / 0.78).clamp(0.0, 1.0),
              );
              final double iconLeft = _lerpDouble(
                iconStartLeft,
                iconEndLeft.clamp(0.0, screen.width),
                posT,
              );
              final double iconTop = _lerpDouble(
                iconStartTop,
                iconEndTop.clamp(0.0, screen.height),
                posT,
              );

              return Stack(
                children: [
                  // centered Groom text (we keep it below icon so icon sits on its dot)
                  Positioned(
                    left: groomLeft,
                    top: groomTop,
                    width: groomWidth,
                    height: groomHeight,
                    child: Opacity(
                      opacity: groomOpacity,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor:
                              1.0, // show entire image; reveal done by fade+mask
                          child: Image.asset(
                            logoTextAsset,
                            key: _groomKey,
                            width: groomWidth,
                            height: groomHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // moving & shrinking icon (keeps its original look)
                  Positioned(
                    left: iconLeft,
                    top: iconTop,
                    width: iconSize,
                    height: iconSize,
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Image.asset(appIconAsset, fit: BoxFit.contain),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
