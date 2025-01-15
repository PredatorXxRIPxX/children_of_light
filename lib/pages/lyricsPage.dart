import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:convert';

import 'package:lumiers/services/appwrite.dart';

class LyricsPage extends StatefulWidget {
  final String title;
  final String fileUrl;

  const LyricsPage({
    super.key,
    required this.title,
    required this.fileUrl,
  });

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  String? _lyrics;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await AppwriteServices.storage
          .listFiles(bucketId: AppwriteConfig.storage, search: widget.fileUrl);

      final bytes = await AppwriteServices.storage.getFileView(
        bucketId: AppwriteConfig.storage,
        fileId: response.files[0].$id,
      );

      final content = utf8.decode(bytes);

      String text = content;

      setState(() {
        _lyrics = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load lyrics: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload02, color: Colors.black),
              onPressed: () async {
                final response = await AppwriteServices.storage.listFiles(
                    bucketId: AppwriteConfig.storage, search: widget.fileUrl);

                final bytes = await AppwriteServices.storage.getFileView(
                  bucketId: AppwriteConfig.storage,
                  fileId: response.files[0].$id,
                );

                final file = File('${widget.title}.txt');
                await file.writeAsBytes(bytes);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lyrics saved to ${file.path}'),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLyrics,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(
              _lyrics ?? 'No lyrics available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
