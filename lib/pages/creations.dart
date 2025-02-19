import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumiers/components/modelsheet.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum FileType { audio, text }

class Creations extends StatefulWidget {
  const Creations({super.key});

  @override
  State<Creations> createState() => _CreationsState();
}

class _CreationsState extends State<Creations> {
  late Future<List<MusicContainer>> _creationsFuture;
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _creationsFuture = _fetchCreations();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<MusicContainer>> _fetchCreations() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Ajoutez ici votre logique de récupération des données
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des créations: $e');
      return [];
    }
  }

  Future<void> _refreshCreations() async {
    setState(() {
      _creationsFuture = _fetchCreations();
    });
  }

  Future<void> _uploadFile(FileType type) async {
  try {
    XFile? pickedFile = await _picker.pickMedia();
    
    if (pickedFile == null) return;

    bool isValidFile = type == FileType.audio ? 
      pickedFile.path.toLowerCase().endsWith('.mp3') :
      pickedFile.path.toLowerCase().endsWith('.txt');

    if (!isValidFile) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Format de fichier invalide. Veuillez sélectionner un fichier ${type == FileType.audio ? '.mp3' : '.txt'}'
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    String fileName = pickedFile.path.split('/').last;
    
    InputFile file = await InputFile.fromPath(
      path: pickedFile.path,
      filename: fileName,
    );

    print('Envoi du fichier $fileName');

    final currentUser = await AppwriteServices.getCurrentUser();
    if(currentUser['success']) {
      final userData = currentUser['user'] as Map<String, dynamic>;
      String creator = userData['\$id'] as String;
      await AppwriteServices.uploadFiles(file, type, fileName,creator);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue lors de l\'upload'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fichier envoyé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      _refreshCreations();
    }

  } catch (e) {
    print('Erreur lors de l\'upload: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue lors de l\'upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Vos créations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: RefreshIndicator(
        onRefresh: _refreshCreations,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<MusicContainer>>(
            future: _creationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Une erreur est survenue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final creations = snapshot.data ?? [];
              if (creations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.primary,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune création pour le moment',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: creations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => creations[index],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => ModalSheet(
              isDismissible: true,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    Container(
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.4,
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      "Choisissez la source de votre musique :",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.music_note),
                            title: const Text('Importer un fichier .mp3'),
                            onTap: () => _uploadFile(FileType.audio),
                          ),
                          ListTile(
                            leading: const Icon(Icons.file_copy),
                            title: const Text('Importer un fichier .txt'),
                            onTap: () => _uploadFile(FileType.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}