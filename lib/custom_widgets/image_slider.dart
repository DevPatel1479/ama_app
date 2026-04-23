import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AutoScrollSlider extends StatefulWidget {
  final List<String> assets;
  final bool reverse;

  const AutoScrollSlider({
    super.key,
    required this.assets,
    this.reverse = false,
  });

  @override
  State<AutoScrollSlider> createState() => _AutoScrollSliderState();
}

class _AutoScrollSliderState extends State<AutoScrollSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final Ticker _ticker;

  List<String> get loopedAssets => [...widget.assets, ...widget.assets];

  double _offset = 0;
  Duration _last = Duration.zero;

  static const double speed = 30; // px/sec

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      if (!_controller.hasClients) return;

      if (_last == Duration.zero) {
        _last = elapsed;
        return;
      }

      final dt = (elapsed - _last).inMilliseconds / 1000;
      _last = elapsed;

      final delta = speed * dt;

      _offset += widget.reverse ? -delta : delta;

      final max = _controller.position.maxScrollExtent;

      if (_offset >= max) _offset -= max;
      if (_offset <= 0) _offset += max;

      _controller.jumpTo(_offset);
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageSize = width * 0.20;

    return RepaintBoundary(
      child: SizedBox(
        height: imageSize,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: loopedAssets.length,
          itemExtent: imageSize + 16, // 🔥 performance key
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? width * 0.04 : 8,
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
      borderRadius: BorderRadius.circular(22),
      child: CachedNetworkImage(
        imageUrl: asset,
        width: size,
        height: size,
        fit: BoxFit.cover,

        memCacheWidth: 300,
        memCacheHeight: 300,

        placeholder: (_, __) => Container(color: Colors.grey[800]),
        errorWidget: (_, __, ___) => Icon(Icons.error),

        fadeInDuration: Duration(milliseconds: 200),
      ),
    );
  }
}
