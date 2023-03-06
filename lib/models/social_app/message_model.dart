class MessageModel
{
  String? senderId;
  String? receiverId;
  String? dateTime;
  String? text;
  String? image;
  bool? isBullying;
  MessageModel({
   this.senderId,
    this.receiverId,
    this.dateTime,
    this.text,
    this.image,
    this.isBullying,
  });
  MessageModel.fromJson(Map<String,dynamic> json)
  {
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    dateTime = json['dateTime'];
    text = json['text'];
    image = json['image'];
    isBullying = json['isBullying'];

  }

  Map<String,dynamic> toMap()
  {
    return {
      'senderId' : senderId,
      'receiverId' : receiverId,
      'dateTime' : dateTime,
      'text' : text,
      'image' : image,
      'isBullying' : isBullying,
    };
  }

}