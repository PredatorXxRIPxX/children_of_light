import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MusicPage extends StatefulWidget {
  final String name;
  final String fileUrl;
  final String? imageUrl;

  const MusicPage({
    super.key,
    required this.name,
    required this.fileUrl,
    this.imageUrl,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _animationController;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _player = AudioPlayer();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      await _player.setUrl(widget.fileUrl).whenComplete(() {
        _player.play();
      });
      _player.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace st) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });

      _player.durationStream.distinct().listen((duration) {
        setState(() => _duration = duration ?? Duration.zero);
      });

      _player.positionStream.distinct().listen((position) {
        setState(() => _position = position);
      });

      _player.bufferedPositionStream.distinct().listen((position) {
        setState(() => _bufferedPosition = position);
      });

      _player.playerStateStream.distinct().listen((state) {
        setState(() {
          _isPlaying = state.playing;
          if (state.playing) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _isPlaying ? _player.pause() : _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDownload02, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 2 * 3.1416,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: widget.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  _defaultAlbumArt(),
                            )
                          : _defaultAlbumArt(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Text(
            widget.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProgressBar(
              progress: _position,
              buffered: _bufferedPosition,
              total: _duration,
              onSeek: (duration) => _player.seek(duration),
              timeLabelLocation: TimeLabelLocation.below,
              timeLabelType: TimeLabelType.totalTime,
              barHeight: 10,
              baseBarColor: Colors.grey[300],
              progressBarColor: Theme.of(context).primaryColor,
              bufferedBarColor: Colors.grey[400],
              thumbColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                onPressed: () => _player.seekToPrevious(),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40),
                onPressed: () => _player.seekToNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAlbumArt() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}
