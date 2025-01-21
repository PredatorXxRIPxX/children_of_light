import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/pages/lyricsPage.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:lumiers/utils/user_provider.dart';
import 'package:provider/provider.dart';

class Listfav extends StatefulWidget {
  const Listfav({super.key});

  @override
  State<Listfav> createState() => _ListfavState();
}

class _ListfavState extends State<Listfav> {
  late UserProvider userProvider;
  List<MusicContainer> favList = [];

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> getFavlist() async {
    try {
      final idUser = await AppwriteServices.getCurrentUser()
          .then((value) => value.entries.last.value['\$id']);
      final listfav = await AppwriteServices.getFavlist(idUser)
          .then((value) => value.entries.last.value);

      List<dynamic> favlyrics = listfav['lyrics'];
      List<dynamic> favmusics = listfav['musics'];

      favlyrics.forEach((element) {
        favList.add(MusicContainer(
          title: element['name'],
          icon: Icons.music_note,
          isFavorite: true,
          onFavoriteToggle: () {
            print('remove from fav');
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LyricsPage(
                  title: element['name'],
                  fileUrl: element['url_file'],
                ),
              ),
            );
          },
        ));
      });

      print(favList);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mes Favoris',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: getFavlist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: favList.length,
                    itemBuilder: (context, index) {
                      return favList[index];
                    },
                  );
                }
              }),
        ));
  }
}
