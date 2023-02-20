import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/wigets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 
 List<ChatUser> list = [];

   // for storing searched items
  final List<ChatUser> _searchList = [];

  // for storing search status
  bool _isSearching = false;

 @override
 void initState(){
  super.initState();
  APIs.getSelfInfo();
 }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected
      onTap:()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);
          } else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          
          appBar:AppBar(
            title: _isSearching? TextField(
                           decoration: const InputDecoration(border: InputBorder.none, hintText: 'Name, Email, ...'),
                            autofocus: true,
                            style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                            onChanged: (val) {
                          //search logic
                          _searchList.clear();
          
                          for (var i in list) {
                            if (i.name.toLowerCase().contains(val.toLowerCase()) ||i.email.toLowerCase().contains(val.toLowerCase())) {
                              _searchList.add(i);
                              setState(() {
                                _searchList;
                              });
                            }
                          }
                        },
                      )
                    :  const Text('We Chat'),
                           
            //title: const Text("We chat"),      
            actions: [
            IconButton(onPressed: () {}, icon:const Icon(Icons.home_outlined) ),
          
            IconButton(onPressed: () {
              setState(() {
              _isSearching=! _isSearching;}
              );
              }, 
              icon: Icon(_isSearching? CupertinoIcons.clear_circled_solid: Icons.search) ),
          
          
            IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(title: "profile",user: APIs.me,)));
            },
             icon:const Icon(Icons.more_vert) ),],),
            
            floatingActionButton:Padding(
             padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(onPressed: ()async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
              child:const Icon(Icons.add_comment_rounded))), //To add new user
            
            
            
              body: StreamBuilder(
                
              stream:APIs.getAllUsers(), 
              //APIs.firestore.collection("users").snapshots(),
              builder: (context, snapshot) {
              switch (snapshot.connectionState) {
          
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            return const Center(child: CircularProgressIndicator());
                              
                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??[];
                               /*           if (list.isNotEmpty) {
                                return  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:list.length,
                                    //padding: EdgeInsets.only(top: mq.height * .01),
                                  physics: const NeverScrollableScrollPhysics(),
                                   // physics: const BouncingScrollPhysics(),
                                   // physics: const ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(user: list[index]);
                                    });
            
                                }*/ 
                              if (list.isNotEmpty) {
                                return  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:_isSearching? _searchList.length: list.length,
                                    //padding: EdgeInsets.only(top: mq.height * .01),
                                  physics: const NeverScrollableScrollPhysics(),
                                   // physics: const BouncingScrollPhysics(),
                                   // physics: const ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(user:_isSearching?_searchList[index]: list[index]);
                                    });
            
                                }
                                else {
                                return const Center(
                                  child: Text('No Connections Found!',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }

        }})),
      ),
    );
  }
}