import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumiers/components/modelsheet.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/pages/lyricsPage.dart';
import 'package:lumiers/pages/musicPage.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FileType { audio, text }

extension FileTypeExtension on FileType {
  String get extension => this == FileType.audio ? '.mp3' : '.txt';
  String get description => this == FileType.audio ? 'musique' : 'texte';
}

class Creations extends StatefulWidget {
  const Creations({super.key});

  @override
  State<Creations> createState() => _CreationsState();
}

class _CreationsState extends State<Creations> {
  late Future<List<GestureDetector>> _creationsFuture;
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _creationsFuture = _fetchCreations();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<GestureDetector>> _fetchCreations() async {
    if (!mounted) return [];

    try {
      setState(() => _isLoading = true);

      final response = await AppwriteServices.getCreations();
      if (!response['success']) {
        throw Exception(response['message']);
      }

      final List<GestureDetector> creations = [];

      final lyricsDocuments = response['response'] as List<dynamic>;
      for (final doc in lyricsDocuments) {
        creations.add(
          GestureDetector(
            child: MusicContainer(
              title: doc.data['name'] as String,
              icon: Icons.music_note,
              isFavorite: false,
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LyricsPage(
                      title: doc.data['name'],
                      fileUrl: doc.data['url_file'],
                    ))),
          ),
        );
      }

      final musicDocuments = response['musicResponse'] as List<dynamic>?;
      if (musicDocuments != null) {
        for (final doc in musicDocuments) {
          creations.add(
            GestureDetector(
              child: MusicContainer(
                title: doc.data['name'] as String,
                icon: Icons.music_note,
                isFavorite: false,
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MusicPage(
                      name: doc.data['name'], fileUrl: doc.data['file_url']))),
            ),
          );
        }
      }

      return creations;
    } catch (e) {
      debugPrint('Error fetching creations: $e');
      return [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshCreations() async {
    if (!mounted) return;
    setState(() {
      _creationsFuture = _fetchCreations();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _uploadFile(FileType type) async {
    try {
      final XFile? pickedFile = await _picker.pickMedia();
      if (pickedFile == null) return;

      final bool isValidFile =
          pickedFile.path.toLowerCase().endsWith(type.extension);
      if (!isValidFile) {
        _showSnackBar(
            'Format de fichier invalide. Veuillez sélectionner un fichier ${type.extension}',
            isError: true);
        return;
      }

      final String fileName = pickedFile.path.split('/').last;
      final InputFile file = await InputFile.fromPath(
        path: pickedFile.path,
        filename: fileName,
      );

      final Map<String, dynamic> currentUser =
          await AppwriteServices.getCurrentUser();
      if (!currentUser['success']) {
        _showSnackBar('Erreur d\'authentification', isError: true);
        return;
      }

      final String creator = currentUser['user']['\$id'] as String;
      final Map<String, dynamic> response =
          await AppwriteServices.uploadFiles(file, type, fileName, creator);

      if (response['success']) {
        _showSnackBar('Fichier de ${type.description} publié avec succès');
        await _refreshCreations();
      } else {
        _showSnackBar('Erreur lors de l\'upload du fichier', isError: true);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      _showSnackBar('Une erreur est survenue lors de l\'upload', isError: true);
    }
  }

  Widget _buildEmptyState() {
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

  Widget _buildErrorState() {
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

  Widget _buildUploadOptionsModal() {
    return ModalSheet(
      isDismissible: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Choisissez la source de votre musique :",
              style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Importer un fichier .mp3'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _uploadFile(FileType.audio);
                      }),
                  ListTile(
                      leading: const Icon(Icons.file_copy),
                      title: const Text('Importer un fichier .txt'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _uploadFile(FileType.text);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          child: FutureBuilder<List<GestureDetector>>(
            future: _creationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  _isLoading) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final creations = snapshot.data ?? [];
              if (creations.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                itemCount: creations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => creations[index],
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
            builder: (_) => _buildUploadOptionsModal(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
