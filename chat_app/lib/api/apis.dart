import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';



class APIs{
   static FirebaseAuth auth=FirebaseAuth.instance;
   static FirebaseFirestore firestore = FirebaseFirestore.instance;
   static FirebaseStorage storage = FirebaseStorage.instance;

   // for storing self information
   static late ChatUser me;

   //to return current user
   static User get user=> auth.currentUser!;

   //to verify if the current user exists
   static Future<bool>userExists()async{
    return(await firestore.collection("users").doc(user.uid).get()).exists;
   }

//to get the current user info
   static Future<void>getSelfInfo() async {
   await firestore.collection("users").doc(user.uid).get().then((user) async {
    if(user.exists){
     me=ChatUser.fromJson(user.data()!);
     await getFirebaseMessagingToken();
     APIs.updateActiveStatus(true);
    } else {
      await createUser().then((value) => getSelfInfo());
    }
    });
   }

    //Create user
   static Future<void>createUser() async{
      final time=DateTime.now().microsecondsSinceEpoch.toString();
      final chatUser=ChatUser(
        id: user.uid, 
        name: user.displayName.toString(),
        email: user.email.toString(), 
        about: "heyy", 
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,  
        pushToken: "");

        return await firestore.collection("users").doc(user.uid).set(chatUser.toJson());
   }

//  getting all users from firestore database
static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
  return firestore.collection("users").where("id",isNotEqualTo:user.uid).snapshots();
}

// for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }
  static Future<void> updateProfilePicture(File file) async {
     // to get the image extension
     final ext=file.path.split(".").last;
    
    // store in a variable the file reference and the path
    final ref =storage.ref().child("profile_pictures/${user.uid}.$ext");

    // upload the image
        await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {log('Data Transferred: ${p0.bytesTransferred / 1000} kb');});
  //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  
  }

  //assecing firebase messaging
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //get firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
     await fMessaging.requestPermission();
     await fMessaging.getToken().then((token) {
      if(token != null){
        me.pushToken=token;
        log('push token:$token');
      }
     });
  }


 // for sending push notification

  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAAJbHDsA:APA91bGKtYr6racU8M09cJc0MkVFiPWCIvHVqB61soYo_-R0-YkSzchWTW65Wwzz3Y_kHopztUq__CULq6A_0_iFh9lw_Z4WY7WopRWXBsdfTj3xEnrBIzH1tgPkJ-NTRzNV_1HQoZ8m'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  } 



  //uuuhhhhhhhhhhhhhhhhhhhh
  
  //To get the  getConversationID
  static String getConversationID(String id)=> user.uid.hashCode<=id.hashCode ? "${user.uid}_$id" : "${id}_${user.uid}" ;

  //get all messages of a specific conver
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection("chats/${getConversationID(user.id)}/messages/").snapshots();
  }


  //sending message

  static Future<void>sendMessage(ChatUser chatUser,String msg,Type type)async {
    //temps d'envoie du message
    final time=DateTime.now().microsecondsSinceEpoch.toString();
    // message a envoyer
    final Message message =Message(
      toid: chatUser.id,
      msg: msg, 
      read:"", 
      type: type, 
      fromid:user.uid, 
      send:time);

      final ref =firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type==Type.text ?msg :'image') );
  }
     
     //update read status of a message 
    static Future<void> updateMessageReadStatus(Message message) async {
      firestore
        .collection('chats/${getConversationID(message.fromid)}/messages/')
        .doc(message.send)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

    //get only last message 
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('send', descending: true).limit(1).snapshots();
  }


 //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {

    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database(envoie)
   final imageUrl= await ref.getDownloadURL();
  await sendMessage(chatUser, imageUrl, Type.image);
  }


  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
        }


  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }
 

}