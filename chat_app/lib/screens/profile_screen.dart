
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../main.dart';




class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required String title, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 final _formKey = GlobalKey<FormState>();
 List<ChatUser> list = [];       //???????????????????????????????
  String ? _image;
  //num ? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
    
          appBar:AppBar(title: const Text("Profile Screen"),),
          
          floatingActionButton:Padding(
           padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(onPressed: ()async {
              //show the progress bar
              Dialogs.showProgressBar(context);
    
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut().then((value) {
                
               //to remove progress bar
                Navigator.pop(context);
                // yo remove home screen
                Navigator.pop(context);
                //Navigate To login screen
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>const LoginScreen()));
              });
            },
            label: const Text("logout"),
             icon:const Icon(Icons.logout))), //To add new user
          
          
          
            body:Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    SizedBox(width: mq.width,height: mq.height * .03,),
                    //Profile pict
                    Stack(
                      children: [             
                        //Profile pict
                        _image != null
                            ?

                            //local image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover))
                            :
                            ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height*.1),
                          child: CachedNetworkImage(
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.fill,
                                    imageUrl: widget.user.image,
                                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                  ),
                        ),
                        //edit profile pict 
                        Positioned(
                          bottom:0,
                          right: 0,
                          child: MaterialButton(
                             shape:const CircleBorder(),
                             elevation: 1,
                             color:Colors.white,
                             child:const Icon(Icons.edit,color: Colors.blue,),
                             onPressed: (){_showBottomSheet();}),
                        ) 
                
                      ],
                    ),
                
                    SizedBox(height: mq.height * .03,),
                    Text(widget.user.email,style: const TextStyle(color:Colors.black,fontSize: 16),),
                
                     // for adding some space
                          SizedBox(height: mq.height * .05),
                          // name input field
                          TextFormField(
                            initialValue: widget.user.name,
                            onSaved: (val) =>APIs.me.name=val ??'' ,
                            validator: (val) =>val != null && val.isNotEmpty ? null : "this feild can not be emty",
                            decoration: InputDecoration(
                                prefixIcon:const Icon(Icons.person, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                hintText: 'eg. Happy Singh',
                                label: const Text('Name')),
                          ),
                
                          // for adding some space
                          SizedBox(height: mq.height * .05),
                        
                          // about input field
                          TextFormField(
                            initialValue: widget.user.about,
                            onSaved: ((val) =>APIs.me.about=val ?? '' ),
                            validator: (val) =>val != null && val.isNotEmpty ? null : "this feild can not be emty",
                            decoration: InputDecoration(
                                prefixIcon:const Icon(Icons.person, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                hintText: 'eg. feeling Happy ',
                                label: const Text('About')),
                          ),
                
                          ElevatedButton.icon(onPressed: (){
                           if(_formKey.currentState!.validate()){_formKey.currentState?.save();}
                           APIs.updateUserInfo().then((value) => Dialogs.showSnackbar(context, "updated with success"));
                          }, 
                          icon: const Icon(Icons.edit), 
                          label: const Text("update"))
                            
                              
                            
                            ],),
                ),
              ),
            )
     ),
    ); }


      // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                     style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
              onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                         // log('Image Path: ${image.path} -- Mime type ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          }
                          
                          );
                         APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                          
                          }
                        },

                      child: Image.asset('images/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: ()  async{
                           final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                         // log('Image Path: ${image.path} -- Mime type ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          }, 
                          );
                                APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                          
                          }

                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}