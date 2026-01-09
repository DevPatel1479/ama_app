import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/scheduler.dart' show Ticker;

class AutoScrollSlider extends StatefulWidget {
  const AutoScrollSlider({super.key});

  @override
  State<AutoScrollSlider> createState() => _AutoScrollSliderState();
}

class _AutoScrollSliderState extends State<AutoScrollSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;

  final List<String> assets = const [
    AppAssets.r1,
    AppAssets.r2,
    AppAssets.r3,
    AppAssets.r4,
    AppAssets.r5,
  ];

  late final List<String> loopedAssets = [...assets, ...assets];

  double _offset = 0.0;
  Duration _lastTick = Duration.zero;

  static const double speed = 30; // px per second (same intent)

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      if (!_scrollController.hasClients) return;

      if (_lastTick == Duration.zero) {
        _lastTick = elapsed;
        return;
      }

      final dt = (elapsed - _lastTick).inMilliseconds / 1000;
      _lastTick = elapsed;

      _offset += speed * dt;

      final max = _scrollController.position.maxScrollExtent;
      if (_offset >= max) {
        _offset -= max;
      }

      _scrollController.jumpTo(_offset);
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.20;

    return RepaintBoundary(
      child: SizedBox(
        height: imageSize,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: loopedAssets.length,
          itemExtent: imageSize + 16, // 🔥 BIG win
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? screenWidth * 0.04 : 8,
                right: 8,
              ),
              child: _ImageTile(asset: loopedAssets[index], size: imageSize),
            );
          },
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String asset;
  final double size;

  const _ImageTile({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: 300,
        cacheHeight: 300,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}
