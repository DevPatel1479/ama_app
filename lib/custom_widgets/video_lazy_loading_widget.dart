import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class LazyVideoPlayer extends StatefulWidget {
  const LazyVideoPlayer({Key? key}) : super(key: key);

  @override
  State<LazyVideoPlayer> createState() => _LazyVideoPlayerState();
}

class _LazyVideoPlayerState extends State<LazyVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = false;
  bool _isPlaying = false;
  bool _hasError = false;
  final String videoUrl = dotenv.env['VIDEO_URL'] ?? '';

  // Use a unique key for VisibilityDetector
  final String _visibilityKey = UniqueKey().toString();

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    try {
      _chewieController?.dispose();
    } catch (_) {}
    try {
      _videoController?.dispose();
    } catch (_) {}
    _chewieController = null;
    _videoController = null;
  }

  Future<void> _initAndPlay() async {
    if (_isInitializing || _videoController != null) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      // Get cached file
      final file = await DefaultCacheManager().getSingleFile(videoUrl);

      if (!mounted) return;

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        allowFullScreen: false,
        allowMuting: true,
        showControlsOnInitialize: true,
        autoInitialize: true,
      );

      setState(() {
        _isPlaying = true;
        _isInitializing = false;
      });
    } catch (e, st) {
      debugPrint('Lazy video init error: $e\n$st');
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  void _pauseIfNotVisible(double visibleFraction) {
    if (_videoController == null) return;
    if (visibleFraction < 0.2 && _videoController!.value.isPlaying) {
      _videoController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    // poster / placeholder UI
    Widget _buildPoster() {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.appLogoWithText, // Use your app logo as thumbnail
              fit: BoxFit.cover,
            ),
          ),
          // dark overlay and play button
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.25),
              child: _isInitializing
                  ? SizedBox(
                      width: 80,
                      height: 80,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade800,
                        highlightColor: Colors.grey.shade700,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _initAndPlay,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.45),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    }

    Widget _buildPlayer() {
      if (_chewieController == null || _videoController == null) {
        return _hasError
            ? const Center(
                child: Text(
                  'Failed to load video',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : _buildPoster();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Chewie(controller: _chewieController!),
      );
    }

    return VisibilityDetector(
      key: Key(_visibilityKey),
      onVisibilityChanged: (info) => _pauseIfNotVisible(info.visibleFraction),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _isPlaying
            ? _buildPlayer()
            : ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _buildPoster(),
              ),
      ),
    );
  }
}
