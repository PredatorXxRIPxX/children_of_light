import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumiers/components/modelsheet.dart';
import 'package:lumiers/components/musiccontainer.dart';
import 'package:lumiers/pages/lyricsPage.dart';
import 'package:lumiers/pages/musicPage.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FileType { 
  audio, 
  text 
}

extension FileTypeExtension on FileType {
  String get extension => this == FileType.audio ? '.mp3' : '.txt';
  String get description => this == FileType.audio ? 'musique' : 'texte';
  IconData get icon => this == FileType.audio ? Icons.music_note : Icons.description;
}

class Creations extends StatefulWidget {
  const Creations({super.key});

  @override
  State<Creations> createState() => _CreationsState();
}

class _CreationsState extends State<Creations> with SingleTickerProviderStateMixin {
  late Future<List<Widget>> _creationsFuture;
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? prefs;
  bool _isLoading = false;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _creationsFuture = _fetchCreations();
    _initPrefs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<Widget>> _fetchCreations() async {
    if (!mounted) return [];

    try {
      setState(() => _isLoading = true);

      final response = await AppwriteServices.getCreations();
      if (!response['success']) {
        throw Exception(response['message']);
      }

      final List<Widget> creations = [];
      final lyricsDocuments = response['response'] as List<dynamic>;
      for (final doc in lyricsDocuments) {
        creations.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SwipeActionCell(
              key: UniqueKey(),
              backgroundColor: Colors.transparent,
              trailingActions: [
                SwipeAction(
                  onTap: (CompletionHandler handler) async {
                    await handler(true);
                    await AppwriteServices.deleteLyrics(doc.$id);
                    _refreshCreations();
                    if (mounted) {
                      _showSnackBar('Texte supprimé avec succès');
                    }
                  },
                  color: Colors.red.shade400,
                  content: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red.shade400,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LyricsPage(
                        title: doc.data['name'],
                        fileUrl: doc.data['url_file'],
                      ),
                    ),
                  ),
                  child: MusicContainer(
                    title: doc.data['name'] as String,
                    icon: FileType.text.icon,
                    isFavorite: false,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      
      final musicDocuments = response['musicResponse'] as List<dynamic>?;
      if (musicDocuments != null) {
        for (final doc in musicDocuments) {
          creations.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SwipeActionCell(
                key: UniqueKey(),
                backgroundColor: Colors.transparent,
                trailingActions: [
                  SwipeAction(
                    onTap: (CompletionHandler handler) async {
                      await handler(true);
                      await AppwriteServices.deleteMusic(doc.$id);
                      _refreshCreations();
                      if (mounted) {
                        _showSnackBar('Musique supprimée avec succès');
                      }
                    },
                    color: Colors.red.shade400,
                    content: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.red.shade400,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MusicPage(
                          name: doc.data['name'],
                          fileUrl: doc.data['file_url'],
                        ),
                      ),
                    ),
                    child: MusicContainer(
                      title: doc.data['name'] as String,
                      icon: FileType.audio.icon,
                      isFavorite: false,
                    ),
                  ),
                ),
              ),
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
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  Future<void> _uploadFile(FileType type) async {
    try {
      final XFile? pickedFile = await _picker.pickMedia();
      if (pickedFile == null) return;

      final bool isValidFile = pickedFile.path.toLowerCase().endsWith(type.extension);
      if (!isValidFile) {
        _showSnackBar(
          'Format de fichier invalide. Veuillez sélectionner un fichier ${type.extension}',
          isError: true,
        );
        return;
      }

      String fileName = pickedFile.path.split('/').last;
      if (fileName.endsWith(type.extension)) {
        fileName = fileName.substring(0, fileName.length - type.extension.length);
      }

      final InputFile file = await InputFile.fromPath(
        path: pickedFile.path,
        filename: fileName,
      );

      final Map<String, dynamic> currentUser = await AppwriteServices.getCurrentUser();
      if (!currentUser['success']) {
        _showSnackBar('Erreur d\'authentification', isError: true);
        return;
      }

      final String creator = currentUser['user']['\$id'] as String;
      final Map<String, dynamic> response = await AppwriteServices.uploadFiles(
        file,
        type,
        fileName,
        creator,
      );

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
            Icons.create_new_folder_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune création pour le moment',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour commencer',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              fontSize: 14,
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
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'Une erreur est survenue',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refreshCreations,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptionsModal() {
    return ModalSheet(
      isDismissible: true,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Ajouter une création",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Ajouter une musique'),
                  subtitle: const Text('Fichier .mp3'),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadFile(FileType.audio);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Ajouter des paroles'),
                  subtitle: const Text('Fichier .txt'),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadFile(FileType.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshCreations,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: FutureBuilder<List<Widget>>(
            future: _creationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final creations = snapshot.data ?? [];
              if (creations.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: creations.length,
                itemBuilder: (_, index) => creations[index],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => _buildUploadOptionsModal(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle création'),
      ),
    );
  }
}