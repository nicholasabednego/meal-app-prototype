part of 'models.dart';

class UserModel {
  String id, name, email;
  List<String> likes, dislikes, history;
  List<Map> locations;
  UserModel(
      this.id, this.name, this.email, this.likes, this.dislikes, this.history, this.locations);
}
