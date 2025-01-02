import 'package:appwrite/appwrite.dart';
 class Appwrite {

  static Client client = Client().setProject('6776c3a3002475c834aa');
  Databases database = Databases(client); 
  Avatars avatars = Avatars(client);
  Storage storage = Storage(client);

}

