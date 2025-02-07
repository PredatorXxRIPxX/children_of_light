import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:convert';

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

  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _localFilePath;
  String? _permanentFilePath;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _player = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _checkPermanentFile();
    if (_permanentFilePath == null) {
      await _checkCachedFile();
    }
  }

  String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);
    return '${hash.toString()}.mp3';
  }

  Future<void> _checkCachedFile() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final fileName = _generateFileName(widget.fileUrl);
      final file = File('${cacheDir.path}/$fileName');

      if (await file.exists()) {
        setState(() {
          _localFilePath = file.path;
        });
        await _setupAudioPlayer(file.path);
      } else {
        await _downloadToCache();
      }
    } catch (e) {
      _showError('Cache check error: $e');
    }
  }

  Future<void> _checkPermanentFile() async {
    try {
      final dir = await _storageDir;
      final fileName = _generateFileName(widget.fileUrl);
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        setState(() {
          _permanentFilePath = file.path;
        });
        await _setupAudioPlayer(file.path);
      }
    } catch (e) {
      _showError('Storage check error: $e');
    }
  }

  Future<Directory> get _storageDir async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${appDocDir.path}/music');
    
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    
    return musicDir;
  }

  Future<void> _downloadToCache() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final cacheDir = await getTemporaryDirectory();
      final fileName = _generateFileName(widget.fileUrl);
      final file = File('${cacheDir.path}/$fileName');

      await _dio.download(
        widget.fileUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _localFilePath = file.path;
      });

      await _setupAudioPlayer(file.path);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showError('Download error: $e');
    }
  }

  Future<void> _saveToStorage() async {
    if (_localFilePath == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await _storageDir;
      final fileName = _generateFileName(widget.fileUrl);
      final sourceFile = File(_localFilePath!);
      final destFile = File('${dir.path}/$fileName');

      await sourceFile.copy(destFile.path);

      setState(() {
        _permanentFilePath = destFile.path;
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song saved to device'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showError('Error saving file: $e');
    }
  }

  Future<void> _setupAudioPlayer(String filePath) async {
    try {
      await _player.setAudioSource(AudioSource.file(filePath));
      
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.playing) {
              _animationController.repeat();
            } else {
              _animationController.stop();
            }
          });
        }
      });

      _player.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });

      _player.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _player.bufferedPositionStream.listen((bufferedPosition) {
        if (mounted) {
          setState(() {
            _bufferedPosition = bufferedPosition;
          });
        }
      });

      await _player.play();
    } catch (e) {
      _showError('Error loading audio: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      _showError('Playback error: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      _showError('Seeking error: $e');
    }
  }

  Widget _buildDownloadIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: _downloadProgress,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            'Downloading... ${(_downloadProgress * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
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
            onPressed: _localFilePath != null && _permanentFilePath == null 
                ? _saveToStorage 
                : null,
            icon: _permanentFilePath != null
                ? const Icon(Icons.check_circle, color: Colors.white)
                : HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload02,
                    color: Colors.white,
                  ),
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
          if (_isDownloading) ...[
            _buildDownloadIndicator(),
          ] else ...[
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
                onSeek: _seekTo,
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