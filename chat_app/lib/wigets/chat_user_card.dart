import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/date_util.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';

import '../main.dart';
import '../models/chat_user.dart';


//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
         
         //Navigate to ChatScreen
          onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user)));},
          
          child:
           StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];
            
            
            
             return ListTile(
                //user profile picture
                leading: InkWell(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                //user name
                title: Text(widget.user.name),
         
                //last message
                subtitle:Text(_message!=null? _message!.msg: widget.user.about,maxLines:1),
                
                //last message time
                trailing: _message==null? null:_message!.read.isEmpty && _message!.fromid !=APIs.user.uid ?

                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green[600],
                  ),
                ) 
                :
                Text(Dialogs.getLastMessageTime(context:context,time:_message!.send),style: TextStyle(color: Colors.black54),),
                
                          
              );
            },
          )
          ),

    );
  }
}

