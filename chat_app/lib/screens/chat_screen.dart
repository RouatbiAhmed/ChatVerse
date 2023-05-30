import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/wigets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //pour stocker tout les message 
  List<Message> _list=[];
  
  final messagecontroller=TextEditingController();

  //hide or show emoji
  bool _showEmoji=false,_isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if back buttton is pressed and emojis are showen the hide them
          onWillPop: () {
            if(_showEmoji){
              setState(() =>_showEmoji = !_showEmoji);
              return Future.value(false);
            }
            else {return Future.value(true);
            }
          },
          child: Scaffold(
            
            appBar: AppBar(automaticallyImplyLeading: false,flexibleSpace: _appBar()),
            
            body: Column(
              children: [
               Expanded(
               child: StreamBuilder(    
                    stream:APIs.getAllMessages(widget.user), 
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
                                     _list=data?.map((e)=>Message.fromJson(e.data())).toList()??[];
            
                                    // log("Data :${jsonEncode(data![0].data())}");
                                    // list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??[];
                                                   
                                    
                                    if (_list.isNotEmpty) {
                                      return  ListView.builder(
                                          reverse: true,
                                          shrinkWrap: true,
                                          itemCount:_list.length,
                                          //padding: EdgeInsets.only(top: mq.height * .01),
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {return MessageCard(message:_list[index]);}
                                                              );
                                                            }
                                      
                                    else {
                                      return const Center(child: Text('HII Freind',style: TextStyle(fontSize: 20)),);
                                           }
             
                     }}),),
                 
                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(alignment: Alignment.centerRight,
                      child: Padding(padding:EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                     child: CircularProgressIndicator(strokeWidth: 2))),



               //input feild
              _chatInput(),
            
            
              if(_showEmoji)   
            SizedBox(
              height: mq.height* .35,
              child:EmojiPicker(    
              textEditingController: messagecontroller,          
              config: Config(
                 columns: 7,
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              ),
             ),
            )
           
              ],),
          ),
        ),
      ),
    );
   
  }










   //APP Bar
   Widget _appBar(){
    return InkWell(
       onTap: () {},

       child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? []; 

      return Row( children:[

        // Back button
        IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.arrow_back)),

        // profile picture
        ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        width: mq.height * .055,
                        height: mq.height * .055,
                        imageUrl:list.isNotEmpty? list[0].name: widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                 ),
        const SizedBox(width: 10,),

        Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //user name
          Text(list.isNotEmpty? list[0].name: widget.user.name,style:const TextStyle(color:Colors.black,fontSize: 16 )),
          
          const SizedBox(height: 2,),

                //last seen time of user
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                                  : MyDateUtil.getLastActiveTime(
                                   context: context,
                                   lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),

        ],)
       ]
      );
    }
    )
    );
    }



    
     Widget _chatInput(){
      return Padding(padding: EdgeInsets.symmetric(vertical: mq.height*.01,horizontal: mq.width*.010),
         child: Row(children: [
          Expanded(
          child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

          child:  Row(children: [
      
           //send emoji button
           IconButton(onPressed: (){setState(() {
            FocusScope.of(context).unfocus();
             _showEmoji=!_showEmoji;
           });}, 
           icon: const Icon(Icons.emoji_emotions,size: 25)),
      
                     //Textform
               Expanded(
                 child:TextField(
                         onTap: () {
                          if(_showEmoji)
                           setState(() =>_showEmoji= !_showEmoji);
                         },
                         controller:messagecontroller ,
                         keyboardType: TextInputType.multiline,
                         maxLines: null,
                         decoration: const InputDecoration(
                         hintText:"type something",
                         border: InputBorder.none,)
                               )
                       ),
      
                       //send image from gallery button
              IconButton(onPressed: () async {
                // Picking multiple images
                        final List<XFile> images =await ImagePicker().pickMultiImage(imageQuality: 70);
                         
                         // uploading & sending image one by one
                        for (var i in images) {
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }

              }, icon: const Icon(Icons.image,size: 25,)),

                          //send image from camera button
              IconButton(onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          //log('Image Path: ${image.path}');
                           setState(() => _isUploading = true);

                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                           setState(() => _isUploading = false);
                        }
                      },
            
               icon: const Icon(Icons.camera_alt,size: 25,)),

            //SizedBox(width: mq.width* .01,)
            ],),
          ),
           
          ),
             MaterialButton(
             onPressed: () {
              if(messagecontroller.text.isNotEmpty){
                APIs.sendMessage(widget.user, messagecontroller.text,Type.text);
                messagecontroller.text="";
              }},
             padding: const EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
             shape: const CircleBorder(),
             color: Colors.red,
             
             child: const Icon(Icons.send,color:Colors.white,size: 25),
             )
        ],
        
        ),
      );
    
     }


}

