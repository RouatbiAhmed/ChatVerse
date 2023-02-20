import 'package:cached_network_image/cached_network_image.dart';
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
  


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {},
          child:
          //  StreamBuilder(
          //   stream: APIs.getLastMessage(widget.user),
          //   builder: (context, snapshot) {
          //     final data = snapshot.data?.docs;
          //     final list =
          //         data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          //     if (list.isNotEmpty) _message = list[0];

          //     return 
              ListTile(
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
                subtitle:Text(widget.user.about),

                //last message time
                trailing:Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green[600],
                  ),
                )
                //Text("12:00 PM",style: TextStyle(color: Colors.black54),),
                
                          
              ),
          //  },
         // )
          ),

    );
  }
}





















// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chat_app/models/chat_user.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import '../main.dart';
// import 'package:chat_app/screens/auth/login_screen.dart';


// class ChatUserCard extends StatefulWidget {
//  //create instance 
//   final ChatUser user;
  
//   const ChatUserCard({super.key, required this.user});
//   @override
//   State<ChatUserCard> createState() => _ChatUserCardState();}

// class _ChatUserCardState extends State<ChatUserCard> {
//   @override
//   Widget build(BuildContext context) {
//      mq = MediaQuery.of(context).size;
//     return Card(
      
     
//      /* child: InkWell(
//         onTap: (){},
//         child: ListTile(title: Text("demo"),),
//       ),*/
//       //margin: EdgeInsets.symmetric(horizontal: mq.width*04,vertical: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 0.5,
//       child: InkWell(
//        onTap: (){},
//        child:  ListTile(
        
//         //User name
//         // title: Text("Demo User"),
//          title: Text(widget.user.name),
//          //Last message
//          subtitle:Text(widget.user.about),
//           //Text("last user message"),
      
//          //User profile picture
//          leading:ClipRRect(
//           borderRadius: BorderRadius.circular(mq.height*.3),
//           child: CachedNetworkImage(
//             imageUrl: widget.user.image,
//             errorWidget: (context,url,error)=>  CircleAvatar(child: Icon(CupertinoIcons.person),),
//           ),
//          ),
//          // CircleAvatar(child: Icon(CupertinoIcons.person),),

//          //last message Time
//          trailing: const Text("12:00 PM",style: TextStyle(color: Colors.black54),),
       
//        ),
//       ),
//     );
//   }
// }