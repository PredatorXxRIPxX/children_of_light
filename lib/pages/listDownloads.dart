import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/pages/musicPage.dart';
import 'package:path_provider/path_provider.dart';


class Listdownloads extends StatefulWidget {
  const Listdownloads({super.key});

  @override
  State<Listdownloads> createState() => _ListdownloadsState();
}

class _ListdownloadsState extends State<Listdownloads> {
  Directory? downloadsDirectory;
  List<FileSystemEntity> files = [];

  Future<Directory> _checkExistenceDirectory() async {
    final temporaryDirectory = await getApplicationDocumentsDirectory();
    final downloadsDirectory = Directory('${temporaryDirectory.path}/music');
    if (!downloadsDirectory.existsSync()) {
      await downloadsDirectory.create(recursive: true);
    }
    return downloadsDirectory;
  }

  Future<void> saveFile(String fileName, String content) async {
    Directory appDirectory = await _checkExistenceDirectory();
    final musicDir = Directory('${appDirectory.path}/music');
    if (!musicDir.existsSync()) {
      await musicDir.create(recursive: true);
    }
    files.addAll(musicDir.listSync());
  }

  Future<String> readFile(String fileName) async {
    Directory appDirectory = await _checkExistenceDirectory();
    File file = File('${appDirectory.path}/$fileName');
    return await file.readAsString();
  }

  @override
  void initState() {
    super.initState();
    _initializeDownloadsDirectory();
  }

  Future<void> _initializeDownloadsDirectory() async {
    downloadsDirectory = await _checkExistenceDirectory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Telechargements',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _checkExistenceDirectory(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Erreur: ${snapshot.error}'),
              );
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasData) {
              final downloadsDirectory = snapshot.data as Directory;
              final files = downloadsDirectory.listSync();
              
              if (files.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucun telechargement',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return MusicContainer(
                    title: file.uri.pathSegments.last.replaceAll('.mp3', ''),
                    icon: Icons.music_note,
                    isFavorite: false,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MusicPage(
                        name: file.path,
                        fileUrl: file.path,
                      ),
                    )),
                  );
                },
              );
            }
            
            return const Center(
              child: Text(
                'Aucun telechargement',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }
}