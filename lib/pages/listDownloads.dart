import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Listdownloads extends StatefulWidget {
  const Listdownloads({super.key});

  @override
  State<Listdownloads> createState() => _ListdownloadsState();
}

class _ListdownloadsState extends State<Listdownloads> {
  Directory? _downloadsDirectory;

  Future<Directory> _checkExistenseDirectory() async {
    final temporaryDirectory = await getApplicationDocumentsDirectory();
    if (temporaryDirectory.existsSync()) {
      await Directory('${temporaryDirectory.path}/downloads').create();
    }
    return temporaryDirectory;
  }

  Future<void> saveFile(String fileName, String content) async {
    Directory appDirectory = await _checkExistenseDirectory();
    File file = File('${appDirectory.path}/$fileName');
    await file.writeAsString(content);
  }

  Future<String> readFile(String fileName) async {
    Directory appDirectory = await _checkExistenseDirectory();
    File file = File('${appDirectory.path}/$fileName');
    return await file.readAsString();
  }

  @override
  void initState() async {
    _downloadsDirectory = await _checkExistenseDirectory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mes Telechargements',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: getDownloadsDirectory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                _downloadsDirectory = snapshot.data as Directory;
                return ListView.builder(
                  itemCount: _downloadsDirectory!.listSync().length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_downloadsDirectory!.listSync()[index].path),
                    );
                  },
                );
              }
              return Center(
                child: Text(
                  'Aucun telechargement',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            },
          ),
        ));
  }
}
