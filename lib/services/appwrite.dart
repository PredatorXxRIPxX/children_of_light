import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:lumiers/pages/lyrics.dart';


class AppwriteConfig {
  static const String projectId = '677ee4b3003777fc3095';
  static const String databaseId = '677ee583000a6aad4d96';
  static const String userCollection = '677ee59b001053a8d575';
  static const String musicCollection = '677ee5af002689ed97fb';
  static const String lyricsCollection = '677ee5bc002053b3c9e1';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String storage = '677ee543002f651f7389';
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
      print('sendVerification:'+response.toString());
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
      print('verify:'+response.toString());
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
                'id_lyrics':lyricsDoc.$id,
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


  static Future <Map<String,dynamic>> updateProfile({
    String username = '',
    String email = '',
    String password = '',
  }) async {
    try {
      var response = null;
      if (username.isNotEmpty) {
        response = await AppwriteServices.account.updateName(name: username);
      }
      if (email.isNotEmpty&&password.isNotEmpty) {
        response = await AppwriteServices.account.updateEmail(email: email, password: password);
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

  static Future <Map<String,dynamic>> getFavlist(String iduser) async {
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

  static Future<Map<String, dynamic>>getMusic(int amount) async {
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

  static Future <Map<String,dynamic>> getMusicQuery(String name) async {
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
}
