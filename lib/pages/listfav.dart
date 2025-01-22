import 'package:flutter/material.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/pages/lyricsPage.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:lumiers/utils/user_provider.dart';
import 'package:provider/provider.dart';

class ListFav extends StatefulWidget {
  const ListFav({super.key});

  @override
  State<ListFav> createState() => _ListFavState();
}

class _ListFavState extends State<ListFav> {
  late final UserProvider _userProvider;
  final List<MusicContainer> _favList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _favList.clear();
    });

    try {
      final userid = await AppwriteServices.getCurrentUser()
          .then((value) => value.entries.last.value['\$id']);
      final favList = await AppwriteServices.getFavlist(userid).then((value)=>value.entries.last.value);

      final favLyrics = favList['lyrics'];
      final favMusics = favList['musics'];

      setState(() {
        for (var lyric in favLyrics) {
          if (lyric != null &&
              lyric is Map<String, dynamic> &&
              lyric['name'] != null) {
            _favList.add(
              MusicContainer(
                title: lyric['name'].toString(),
                icon: Icons.music_note,
                isFavorite: true,
                onTap: () => _navigateToLyrics(lyric),
              ),
            );
          }
        }
        for(var music in favMusics){
          if (music != null &&
              music is Map<String, dynamic> &&
              music['name'] != null) {
            _favList.add(
              MusicContainer(
                title: music['name'].toString(),
                icon: Icons.music_note,
                isFavorite: true,
                onTap: () => _navigateToLyrics(music),
              ),
            );
          }
        };
      });
    } catch (e) {
      print('Error in _loadFavorites: $e'); 
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorites: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLyrics(Map<String, dynamic> lyric) {
    print('Navigating to lyrics: $lyric');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LyricsPage(
          title: lyric['name'].toString(),
          fileUrl: lyric['url_file'].toString(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_favList.isEmpty) {
      return const Center(
        child: Text(
          'No favorites yet',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        itemCount: _favList.length,
        itemBuilder: (context, index) => _favList[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Favoris',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildContent(),
      ),
    );
  }
}
