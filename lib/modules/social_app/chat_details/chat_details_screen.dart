
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
  // final ScrollController _scrollController = ScrollController();






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


  @override
  Widget build(BuildContext context)
  {

    return Builder(builder: (BuildContext context)
    {
      SocialCubit.get(context).getMessages(receiverId: userModel!.uId!,);
      return BlocConsumer<SocialCubit,SocialStates>(
        listener: (context,state){
          // if (state is SocialSendMessageSuccessState)
          //   {
          //     _scrollController.animateTo(
          //       _scrollController.position.maxScrollExtent,
          //       duration: const Duration(milliseconds: 200),
          //       curve: Curves.easeOut,
          //     );
          //   }
          // else if(state is SocialGetMessagesSuccessState)
          //   {
          //     WidgetsBinding.instance!.addPostFrameCallback((_) {
          //       _scrollController.animateTo(
          //         _scrollController.position.maxScrollExtent,
          //         duration: const Duration(milliseconds: 200),
          //         curve: Curves.easeOut,
          //       );
          //     });
          //   }
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
                              // controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index)  {
                                var message = SocialCubit.get(context).messages[index];
                                if (SocialCubit.get(context).userModel!.uId == message.senderId) {
                                  return FutureBuilder<String>(
                                    future: fetchData(message.text!.trim()),
                                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.data == 'not_cyberbullying') {
                                          return buildMyMessage(message);
                                        } else {
                                          return buildWarningMessage('This is Not cool');
                                        }
                                      } else {
                                        return buildLoadingMessage(); // Show a loading indicator
                                      }
                                    },
                                  );
                                }
                                return buildMessage(message);
                              },
                              separatorBuilder: (context, index) => const SizedBox(
                                height: 15.0,
                              ),
                              itemCount: SocialCubit.get(context).messages.length,
                            ),

                            // ListView.separated(
                            //   physics: const BouncingScrollPhysics(),
                            //   controller: _scrollController,
                            //   itemBuilder: (context, index)  {
                            //
                            //     if(SocialCubit.get(context).isWarning) {
                            //       SocialCubit.get(context).changeWarningVariable(isWarning);
                            //       return buildWarningMessage('This is Cyberbullying');
                            //     }
                            //
                            //     var message = SocialCubit.get(context).messages[index];
                            //     if (SocialCubit.get(context).userModel!.uId == message.senderId) {
                            //           return buildMyMessage(message);
                            //     }
                            //     return buildMessage(message);
                            //   },
                            //   separatorBuilder: (context, index) => const SizedBox(
                            //     height: 15.0,
                            //   ),
                            //   itemCount: SocialCubit.get(context).messages.length,
                            // ),
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
                      const Center(
                        child: Text(
                          'No messages found.',
                          style: TextStyle(fontSize: 18.0),
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

  Widget buildLoadingMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildWarningMessage(String warningText) {
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


  Widget buildMyMessage(MessageModel? model) {
    if (model!.text == '')
    {
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
            child:
            Image.network(
              model.image!,
              height: 200.0,
              width: 200.0,
              fit: BoxFit.fill,
            )
        ),
      );
    }
    else
    {
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
            child: Text(model.text!)
        ),
      );
    }
  }

  Widget? buildMessage(MessageModel? model)
  {
    if (model!.text == '' && model.isBullying == false)
      {
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
            child: Image.network(model.image!,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.fill,),
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

 }





//   Widget buildWarningMessage() => Align(
//     alignment: AlignmentDirectional.centerEnd,
//     child: Container(
//       decoration: const BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadiusDirectional.only(
//           bottomStart: Radius.circular(10.0,),
//           topStart: Radius.circular(10.0,),
//           topEnd: Radius.circular(10.0,),
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(
//         vertical: 5.0,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(
//             width: 5.0,
//           ),
//           const Icon(
//             Icons.warning_amber_rounded,
//             color:Colors.white,
//           ),
//           const SizedBox(
//             width: 15.0,
//           ),
//           Text(
//             'This is Cyberbullying'+' ('+QueryText.toString()+' + 'Message won't go')',
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(
//             width: 15.0,
//           ),
//         ],
//       ),
//     ),
//   );
// }
