import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/components/searchbar.dart';
import 'package:lumiers/pages/lyricsPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lumiers/services/appwrite.dart';

class Lyrics extends StatefulWidget {
  const Lyrics({super.key});

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> {
  static const int _pageSize = 10;
  static const int _shimmerCount = 5;
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();
  final FocusNode _searchFocusNode = FocusNode();

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<Document> _lyrics = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitialLyrics();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialLyrics() async {
    try {
      final result = await _fetchLyrics();
      setState(() {
        _lyrics = result;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<List<Document>> _fetchLyrics() async {
    final docList = await AppwriteServices.getLyrics(_currentPage * _pageSize);
    return docList.entries.last.value;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final newLyrics = await _fetchLyrics();

      if (newLyrics.isEmpty) {
        setState(() => _hasMoreData = false);
      } else {
        setState(() {
          _lyrics.addAll(newLyrics);
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _lyrics.clear();
    });
    await _fetchInitialLyrics();
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      _fetchInitialLyrics();
    } else {
      try {
        final result = await AppwriteServices.getLyricsQuery(query);

        setState(() {
          _lyrics = result.entries.last.value;
          _error = null;
        });
      } catch (e) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchAppBar(
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSearch: _onSearch,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: _fetchInitialLyrics,
      );
    }

    if (_lyrics.isEmpty && !_isLoadingMore) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _lyrics.length + (_isLoadingMore ? _shimmerCount : 0),
        itemBuilder: (context, index) {
          if (index < _lyrics.length) {
            return _LyricItem(lyric: _lyrics[index]);
          }
          return const _ShimmerItem();
        },
      ),
    );
  }
}

class _LyricItem extends StatefulWidget {
  final Document lyric;

  const _LyricItem({required this.lyric});

  @override
  State<_LyricItem> createState() => _LyricItemState();
}

class _LyricItemState extends State<_LyricItem> {
  bool isFavorite = false;

  Future<void> _onFavoriteToggle() async {
    try {
      final userid = await AppwriteServices.getCurrentUser()
          .then((value) => value.entries.last.value)
          .then((value) => value['\$id']);
      final response =
          await AppwriteServices.setLyricsToFav(widget.lyric, userid);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lyric added to favorites'),
            backgroundColor: Colors.green[300],
          ),
        );
        setState(() {
          isFavorite = !isFavorite;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Failed to add lyric to favorites'),
            backgroundColor: Colors.red[300],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[300],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      title: widget.lyric.data['name'],
      icon: HugeIcons.strokeRoundedMusicNote01,
      isFavorite: isFavorite,
      onFavoriteToggle: _onFavoriteToggle,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LyricsPage(
              title: widget.lyric.data['name'],
              fileUrl: widget.lyric.data['url_file'],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  const _ShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MusicContainer(
        title: '',
        icon: HugeIcons.strokeRoundedMusicNote01,
        isFavorite: false,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No lyrics found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adding some lyrics or check back later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
