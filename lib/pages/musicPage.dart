import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Musicpage extends StatefulWidget {
  final String name;
  final String fileUrl;
  final String? imageUrl;

  const Musicpage({
    super.key,
    required this.name,
    required this.fileUrl,
    this.imageUrl,
  });

  @override
  State<Musicpage> createState() => _MusicpageState();
}

class _MusicpageState extends State<Musicpage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _animationController;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

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
      await _player.setUrl(widget.fileUrl);
      
      // Listen to duration changes
      _player.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });

      // Listen to position changes
      _player.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      // Listen to player state
      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
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
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [

          IconButton(
            onPressed: () {},
            icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDownload02, color: Colors.black),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Implement favorite functionality
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: RotationTransition(
              turns: _animationController,
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
              total: _duration,
              onSeek: (duration) {
                _player.seek(duration);
              },
              barHeight: 5,
              thumbRadius: 8,
              progressBarColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                onPressed: () {
                  // Implement previous track
                },
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
                onPressed: () {
                  // Implement next track
                },
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