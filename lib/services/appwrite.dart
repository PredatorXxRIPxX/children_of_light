import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lumiers/pages/creations.dart';

class AppwriteConfig {
  static String projectId = dotenv.env['PROJECT_ID'] ?? '';
  static String databaseId = dotenv.env['DATABASE_ID'] ?? '';
  static String userCollection = dotenv.env['USERCOLLECTION_ID'] ?? '';
  static String musicCollection = dotenv.env['MUSICCOLLECTION_ID'] ?? '';
  static String lyricsCollection = dotenv.env['LYRICSCOLLECTION_ID'] ?? '';
  static String endpoint = dotenv.env['END_POINT'] ?? '';
  static String storage = dotenv.env['STORAGE_ID'] ?? '';
}

class AppwriteServices {
  static final Client client = Client()
    ..setEndpoint(AppwriteConfig.endpoint)
    ..setProject(AppwriteConfig.projectId);

  static final Databases db = Databases(client);
  static final Storage storage = Storage(client);
  static final Avatars avatars = Avatars(client);
  static final Account account = Account(client);

  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final existingUsers = await db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userCollection,
        queries: [Query.equal('email', email)],
      );

      if (existingUsers.documents.isNotEmpty) {
        return {
          'success': false,
          'message': 'User already exists',
        };
      }

      final id_user = ID.unique();

      await db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userCollection,
        documentId: id_user,
        data: {
          'id_user': id_user,
          'email': email,
          'username': username,
        },
      );

      final user = await account.create(
        userId: id_user,
        email: email,
        password: password,
      );

      return {
        'success': true,
        'message': 'User created successfully',
        'userId': user.$id,
      };
    } on AppwriteException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'An error occurred during signup',
        'code': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required bool stayConnected,
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      if (!stayConnected) {
        await account.deleteSession(sessionId: session.$id);
      }

      final user = await account.get();

      return {
        'success': true,
        'message': 'Signed in successfully',
        'userId': user.$id,
        'sessionId': session.$id,
      };
    } on AppwriteException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'An error occurred during signin',
        'code': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<bool> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      return true;
    } on AppwriteException catch (e) {
      print('Error during sign out: ${e.message}');
      return false;
    } catch (e) {
      print('Error during sign out: ${e.toString()}');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = await account.get();

      return {
        'success': true,
        'user': user.toMap(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Not authenticated',
      };
    }
  }

  static Future<Map<String, dynamic>> sendVerification({
    required String email,
  }) async {
    try {
      final response = await account.createVerification(
        url: 'internal',
      );
      print('sendVerification:' + response.toString());
      return {
        'success': true,
        'message': 'Recovery email sent',
        'response': response,
      };
    } on AppwriteException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'An error occurred during password recovery',
        'code': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> verifyAccount({
    required String email,
    required String code,
  }) async {
    try {
      final response = await account.updateVerification(
        userId: 'current',
        secret: code,
      );
      print('verify:' + response.toString());
      return {
        'success': true,
        'message': 'Account verified',
        'response': response,
      };
    } on AppwriteException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'An error occurred during account verification',
        'code': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updatePassword(String password) async {
    try {
      final response = await account.updatePassword(password: password);
      return {
        'success': true,
        'message': 'Password updated successfully',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getCurrentSession() async {
    try {
      return {
        'success': true,
        'message': 'Session retrieved successfully',
        'response': await account.getSession(sessionId: 'current'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getUsername({
    required String email,
  }) async {
    try {
      final user = await db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.userCollection,
          queries: [
            Query.select(['username']),
            Query.equal('email', email),
          ]);

      return {
        'success': true,
        'message': 'Username retrieved successfully',
        'username': user.documents[0].data['username'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getLyrics(int amount) async {
    try {
      final documents = await db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.lyricsCollection,
          queries: [
            Query.select(['name', 'url_file']),
            Query.limit(amount),
          ]);
      return {
        'success': true,
        'message': 'Lyrics retrieved successfully',
        'lyrics': documents.documents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getLyricsQuery(String name) async {
    try {
      final response = await AppwriteServices.db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.lyricsCollection,
          queries: [
            Query.search('name', name),
          ]);
      return {
        'success': true,
        'message': 'Lyrics retrieved successfully',
        'lyrics': response.documents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> setLyricsToFav(
      Document lyricsDoc, String iduser) async {
    try {
      final currentdata = await AppwriteServices.db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.userCollection,
          documentId: iduser);
      final response = await AppwriteServices.db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.userCollection,
          documentId: iduser,
          data: {
            'lyrics': [
              ...currentdata.data['lyrics'],
              {
                'id_lyrics': lyricsDoc.$id,
                'name': lyricsDoc.data['name'],
                'url_file': lyricsDoc.data['url_file'],
              }
            ]
          });
      return {
        'success': true,
        'message': 'Lyrics added to favorite',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String username = '',
    String email = '',
    String password = '',
  }) async {
    try {
      var response = null;
      if (username.isNotEmpty) {
        response = await AppwriteServices.account.updateName(name: username);
      }
      if (email.isNotEmpty && password.isNotEmpty) {
        response = await AppwriteServices.account
            .updateEmail(email: email, password: password);
      }
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getFavlist(String iduser) async {
    try {
      final response = await AppwriteServices.db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userCollection,
        documentId: iduser,
      );

      final lyrics = response.data['lyrics'];
      final musics = response.data['musics'];

      return {
        'success': true,
        'message': 'Favorite list retrieved successfully',
        'response': {
          'lyrics': lyrics,
          'musics': musics,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getMusic(int amount) async {
    try {
      final documents = await db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.musicCollection,
          queries: [
            Query.select(['name', 'file_url']),
            Query.limit(amount),
          ]);
      return {
        'success': true,
        'message': 'Music retrieved successfully',
        'response': documents.documents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getMusicQuery(String name) async {
    try {
      final response = await AppwriteServices.db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.musicCollection,
          queries: [
            Query.search('name', name),
          ]);
      return {
        'success': true,
        'message': 'Music retrieved successfully',
        'response': response.documents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> uploadFiles(InputFile file,
      FileType filetype, String filename, String creator) async {
    try {
      final fileid = ID.unique();
      final response = await AppwriteServices.storage.createFile(
          bucketId: AppwriteConfig.storage, fileId: fileid, file: file);
      if (filetype == FileType.text) {
        await AppwriteServices.db.createDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.lyricsCollection,
            documentId: ID.unique(),
            data: {
              'id_lyrics': ID.unique(),
              'name': filename,
              'createdby': creator,
              'url_file':
                  'https://cloud.appwrite.io/v1/storage/buckets/$AppwriteConfig.storage/files/$fileid/view?project=$AppwriteConfig.projectId&mode=admin',
            });
      } else if (filetype == FileType.audio) {
        await AppwriteServices.db.createDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.musicCollection,
            documentId: ID.unique(),
            data: {
              'id_musics': ID.unique(),
              'name': filename,
              'createdby': creator,
              'file_url':
                  'https://cloud.appwrite.io/v1/storage/buckets/$AppwriteConfig.storage/files/$fileid/view?project=$AppwriteConfig.projectId&mode=admin',
            });
      }
      return {
        'success': true,
        'message': 'File uploaded successfully',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getCreations() async {
    try {
      final userid = await AppwriteServices.getCurrentUser();
      if (!userid['success']) {
        return {
          'success': false,
          'message': 'Failed to get current user',
        };
      }

      final responseLyrics = await AppwriteServices.db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.lyricsCollection,
          queries: [Query.equal('createdby', userid['user']['\$id'])]);

      final responseMusics = await AppwriteServices.db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.musicCollection,
          queries: [Query.equal('createdby', userid['user']['\$id'])]);

      return {
        'success': true,
        'message': 'Creations retrieved successfully',
        'response': responseLyrics.documents,
        'musicResponse': responseMusics.documents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteLyrics(String docid) async {
    try {
      final response = await AppwriteServices.db.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.lyricsCollection,
          documentId: docid);
      return {
        'success': true,
        'message': 'Lyrics deleted successfully',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteMusic(String docid) async {
    try {
      final response = await AppwriteServices.db.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.musicCollection,
          documentId: docid);
      return {
        'success': true,
        'message': 'Music deleted successfully',
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
