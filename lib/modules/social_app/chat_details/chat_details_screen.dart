
import 'dart:convert';

import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/models/social_app/message_model.dart';
import 'package:first_app/models/social_app/social_user_model.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:first_app/shared/styles/colors.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;



class ChatDetailsScreen extends StatelessWidget {
  SocialUserModel? userModel;
  var url;
  var queryText;
  ChatDetailsScreen({super.key, this.userModel,});
  var messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();




  @override
  Widget build(BuildContext context)
  {

    return Builder(builder: (BuildContext context)
    {
      SocialCubit.get(context).getMessages(receiverId: userModel!.uId!,);
      return BlocConsumer<SocialCubit,SocialStates>(
        listener: (context,state){
          if (state is SocialSendMessageSuccessState)
            {
              scrollDown();
            }
        },

        builder: (context,state)
        {
          return
             Scaffold(
              appBar: AppBar(
                titleSpacing: 0.0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(
                        userModel!.image!,
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      userModel!.name!,
                    ),
                  ],
                ),
              ),
              resizeToAvoidBottomInset: true,

              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: [
                      Column(
                        children: [
                          Expanded(
                            child:
                              ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                controller: _scrollController,
                                itemCount: SocialCubit.get(context).messages.length,
                                separatorBuilder: (context, index) => const SizedBox(
                                  height: 15.0,
                                ),
                                itemBuilder: (context, index) {
                                  var message = SocialCubit.get(context).messages[index];
                                  bool isCurrentUserMessage = SocialCubit.get(context).userModel!.uId == message.senderId;
                                  bool? isCyberbullying = message.isBullying; // assuming there's a boolean field 'isCyberbullying' in the message model

                                  if (isCurrentUserMessage) {
                                    if (isCyberbullying!) {
                                      // if this is the user's message and it's cyberbullying, display a warning message
                                      return buildWarningMessage('This is Not cool');
                                    } else {
                                      // if this is the user's message and it's not cyberbullying, display the user's message
                                      return buildMyMessage(message,context);
                                    }
                                  } else {
                                    // if this is not the user's message, display the message normally
                                    if (isCyberbullying == true) {
                                      // if this is not the user's message and it's cyberbullying, don't display the message
                                      return SizedBox.shrink();
                                    } else {
                                      // if this is not the user's message and it's not cyberbullying, display the message

                                      return buildMessage(message,context);
                                    }
                                  }
                                },
                              ),
                          ),
                          const SizedBox(height: 10.0,),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message here...',
                                      contentPadding: EdgeInsets.all(10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                MaterialButton(
                                  onPressed: () {
                                    SocialCubit.get(context).getMessageImage();
                                  },
                                  minWidth: 1.0,
                                  child: const Icon(
                                    IconBroken.Image,
                                    size: 22.0,
                                    color: defaultColor,
                                  ),
                                ),
                                 const SizedBox(width: 10.0),
                                SizedBox(
                                  height: 50.0,
                                  child:
                                  MaterialButton(
                                    onPressed: () async {
                                      queryText = await fetchData(messageController.text.trim());
                                      if(queryText != 'not_cyberbullying')
                                        {
                                          if (messageController.text.isNotEmpty || messageImg != null) {
                                            scrollDown();
                                            SocialCubit.get(context).sendMessage(
                                              receiverId: userModel!.uId!,
                                              dateTime: DateTime.now().toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              warning: true,
                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            // Scroll to the last message
                                            //0scrollDown();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please enter some text or select an image.')),
                                            );
                                          }
                                        }
                                      else
                                        {
                                          if (messageController.text.isNotEmpty || messageImg != null) {
                                            scrollDown();

                                            SocialCubit.get(context).sendMessage(
                                              receiverId: userModel!.uId!,
                                              dateTime: DateTime.now().toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              warning: false,
                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            // Scroll to the last message
                                            //0scrollDown();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please enter some text or select an image.')),
                                            );
                                          }
                                        }
                                    },
                                    minWidth: 1.0,
                                    color: defaultColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: const Icon(
                                      IconBroken.Send,
                                      size: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    //GoToBottomButton(scrollController: _scrollController),

                    if (SocialCubit.get(context).messages.isEmpty)
                      const Positioned(
                          bottom: 80.0,
                          left: 10.0,
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: defaultColor,
                            ),
                          ),
                        ),

                    if (SocialCubit.get(context).state is SocialSendMessageErrorState)
                      const Positioned(
                        bottom: 80.0,
                        left: 10.0,
                        child: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: defaultColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );

        },
      );
    },
    );
  }

  Widget? buildMessage(MessageModel? model,BuildContext context)
  {
    if (model!.text == '')
    {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('Image'),
                  ),
                  body: Center(
                    child: Hero(
                      tag: 'image${model.image}',
                      child: Image.network(model.image!),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Hero(
            tag: 'image${model.image}',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(10.0,),
                  topStart: Radius.circular(10.0,),
                  topEnd: Radius.circular(10.0,),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Image.network(
                model.image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );

    }


    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10.0,),
            topStart: Radius.circular(10.0,),
            topEnd: Radius.circular(10.0,),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text('${model.text}'),
      ),
    );
  }

  Widget buildMyMessage(MessageModel? model,BuildContext context) {
    if (model!.text == '') {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('Image'),
                  ),
                  body: Center(
                    child: Hero(
                      tag: 'image${model.image}',
                      child: Image.network(model.image!),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Hero(
            tag: 'image${model.image}',
            child: Container(
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(0.2,),
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(10.0,),
                  topStart: Radius.circular(10.0,),
                  topEnd: Radius.circular(10.0,),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Image.network(
                model.image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: BoxDecoration(
          color: defaultColor.withOpacity(0.2,),
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10.0,),
            topStart: Radius.circular(10.0,),
            topEnd: Radius.circular(10.0,),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text(model.text!),
      ),
    );


  }

  Widget buildWarningMessage(String warningText,) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10.0),
            topStart: Radius.circular(10.0),
            topEnd: Radius.circular(10.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Text(
          warningText,
          style: const TextStyle(
              color: Colors.white
          ),),
      ),
    );
  }

  void scrollDown()

  {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<String> fetchData(String? queryString) async {
    final response = await http.get(Uri.parse('http://192.168.1.32:5000?query=$queryString'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['prediction'];
      return data;

    } else {
      throw Exception('Failed to load data');
    }
  }


 }

