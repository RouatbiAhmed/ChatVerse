class Message {
  Message({
    required this.toid,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromid,
    required this.send,
  });
  late final String toid;
  late final String msg;
  late final String read;
  late final Type type;
  late final String fromid;
  late final String send;
  
  Message.fromJson(Map<String, dynamic> json){
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() ==Type.image.name ?Type.image : Type.text ;
    fromid = json['fromid'].toString();
    send = json['send'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toid'] = toid;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromid'] = fromid;
    data['send'] = send;
    return data;
  }
}
enum Type{text,image}