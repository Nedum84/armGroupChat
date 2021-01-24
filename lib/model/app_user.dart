
class AppUser {
  String uid;
  String name;
  String email;
  int dateRegistered;

  AppUser({
    this.uid,
    this.name,
    this.email,
    this.dateRegistered,
  });

  Map toMap(AppUser user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data["date_registered"] = user.dateRegistered;
    return data;
  }

  // Named constructor
  AppUser.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.dateRegistered = mapData['date_registered'];
  }
}
