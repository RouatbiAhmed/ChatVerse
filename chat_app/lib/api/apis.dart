import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



class APIs{
   static FirebaseAuth auth=FirebaseAuth.instance;
   static FirebaseFirestore firestore = FirebaseFirestore.instance;
   static FirebaseStorage storage = FirebaseStorage.instance;

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
    }else{
      await createUser().then((value) => getSelfInfo());
    }
    });
   }


   static Future<void>createUser()async{
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

}