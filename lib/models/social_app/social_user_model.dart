class SocialUserModel
{
  String? name;
  String? email;
  String? phone;
  String? uId;
  bool? isEmailVerified;
  String? image;
  String? cover;
  String? bio;
  SocialUserModel({
   this.email,
    this.phone,
    this.name,
    this.uId,
    this.isEmailVerified,
    this.image,
    this.bio,
    this.cover,
  });
  SocialUserModel.fromJson(Map<String,dynamic> json)
  {
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    uId = json['uId'];
    image = json['image'];
    isEmailVerified = json['isEmailVerified'];
    bio = json['bio'];
    cover = json['cover'];
  }

  Map<String,dynamic> toMap()
  {
    return {
      'name' : name,
      'email' : email,
      'phone' : phone,
      'uId' : uId,
      'image' : image,
      'bio' : bio,
      'cover' : cover,
      'isEmailVerified' : isEmailVerified,
    };
  }
  void clear()
  {
    name='';
    email='';
    cover='';
    image ='';
    bio='';
    phone='';
    uId='';
  }

}