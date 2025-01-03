import 'dart:core';
import 'package:appwrite/appwrite.dart';

class AppwriteConfig {
  static const String projectId = '6777eaa7002148c96310';
  static const String databaseId = '6777ec1b00016087c593';
  static const String userCollection = '6777ec7d0023d9a6ffa5';
  static const String musicCollection = '6777ee460016fa0d923a';
  static const String lyricsCollection = '6777ee69002b7f322b61';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
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

      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      await db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userCollection,
        documentId: user.$id,
        data: {
          'email': email,
          'username': username,
        },
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
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

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
    } catch (e) {
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

  static Future<Map<String,dynamic>>updatePassword(String password) async{
    try {
      final resposne = await AppwriteServices.account.updatePassword(password:password);
      return {
        'success': true,
        'message': 'Password updated successfully',
        'response': resposne,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
