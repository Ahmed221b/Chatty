
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/models/social_app/message_model.dart';
import 'package:first_app/models/social_app/social_user_model.dart';
import 'package:first_app/modules/social_app/chat_details/ban_systen.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:first_app/shared/styles/colors.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../shared/components/components.dart';
import '../../../shared/network/local/chache_helper.dart';
import '../social_login/social_login_screen.dart';
import 'image_message_screen.dart';



enum CounterType { age, religion, gender, ethnicity, other }



class ChatDetailsScreen extends StatelessWidget {

  SocialUserModel? userModel;
  late SocialUserModel currentUser;
  var url;
  var queryText;
  int sum = 0;
  ChatDetailsScreen({super.key, this.userModel,});
  var messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  BanSystem banSystem = BanSystem();


  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<String> fetchData(String? queryString) async {
    final response = await http.get(Uri.parse('http://192.168.1.32:5000//?query=$queryString'));

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
          if (state is SocialSendMessageSuccessState || state is  SocialRecieveMessageSuccessState)
          {
            scrollDown();
          }
          else if (state is SocialGetMessagesSuccessState)
          {
            scrollDown();
          }
        },
        builder: (context,state)
        {
          return
            Theme(
              data:  ThemeData(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  backwardsCompatibility: false,
                ),
              ),
              child: Scaffold(
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
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
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
                                    print('Sent Bullying');
                                    return buildWarningMessage('This is Bullying');
                                  }
                                  else
                                  {
                                    // if this is the user's message and it's not cyberbullying, display the user's message
                                    print('Sent Normal');
                                    return buildMyMessage(message,context);
                                  }
                                }
                                else {
                                  // if this is not the user's message, display the message normally
                                  if (isCyberbullying == true) {
                                    // if this is not the user's message and it's cyberbullying, don't display the message
                                    return SizedBox.shrink();
                                  } else {
                                    // if this is not the user's message and it's not cyberbullying, display the message
                                    print('Received');
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
                                    messageImg = '';
                                    SocialCubit.get(context).getMessageImage();
                                    navigateTo(context, ImageUploaded(userModel: userModel,));
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
                                      currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                      sum = currentUser.sumOfCounters!;

                                      queryText = await fetchData(messageController.text.trim());
                                      if (currentUser.isBanned == false)
                                      {
                                        if (queryText != 'not_cyberbullying') {
                                          if (messageController.text.isNotEmpty) {
                                            switch (queryText) {
                                              case 'age':
                                                banSystem.updateUserCounter(loggedID!, CounterType.age, currentUser.ageCounter! + 1);
                                                sum += 1;
                                                currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                if (currentUser.ageCounter == 3)
                                                  {
                                                    banSystem.tempBan(loggedID!, true);
                                                    banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                    banSystem.updateUserCounter(loggedID!, CounterType.age, 0);
                                                    currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                    if (currentUser.numberOfBans! >= 5)
                                                      {
                                                        banSystem.updateUserState(loggedID!, true);
                                                        banSystem.userLogout(context);
                                                        navigateAndfFinish(context, SocialLoginScreen());
                                                      }
                                                  }
                                                break;
                                              case 'religion':
                                                banSystem.updateUserCounter(loggedID!, CounterType.religion, currentUser.religionCounter! + 1);
                                                sum += 1;
                                                currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                if (currentUser.religionCounter == 2)
                                                {
                                                  banSystem.tempBan(loggedID!, true);
                                                  banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                  banSystem.updateUserCounter(loggedID!, CounterType.religion, 0);
                                                  currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                  if (currentUser.numberOfBans! >= 5)
                                                  {
                                                    banSystem.updateUserState(loggedID!, true);
                                                    banSystem.userLogout(context);
                                                    navigateAndfFinish(context, SocialLoginScreen());
                                                  }

                                                }
                                                break;
                                              case 'ethnicity':
                                                banSystem.updateUserCounter(loggedID!, CounterType.ethnicity, currentUser.ethnicityCounter! + 1);
                                                sum += 1;
                                                currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                if (currentUser.ethnicityCounter == 4)
                                                {
                                                  banSystem.tempBan(loggedID!, true);
                                                  banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                  banSystem.updateUserCounter(loggedID!, CounterType.ethnicity, 0);
                                                  currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                  if (currentUser.numberOfBans! >= 5)
                                                  {
                                                    banSystem.updateUserState(loggedID!, true);
                                                    banSystem.userLogout(context);
                                                    navigateAndfFinish(context, SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'gender':
                                                banSystem.updateUserCounter(loggedID!, CounterType.gender, currentUser.genderCounter! + 1);
                                                sum += 1;
                                                currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                if (currentUser.genderCounter == 6)
                                                {
                                                  banSystem.tempBan(loggedID!, true);
                                                  banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                  banSystem.updateUserCounter(loggedID!, CounterType.gender, 0);
                                                  currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                  if (currentUser.numberOfBans! >= 5)
                                                  {
                                                    banSystem.updateUserState(loggedID!, true);
                                                    banSystem.userLogout(context);
                                                    navigateAndfFinish(context, SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              case 'other_cyberbullying':
                                                banSystem.updateUserCounter(loggedID!, CounterType.other, currentUser.otherCounter! + 1);
                                                sum += 1;
                                                currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                if (currentUser.otherCounter == 6)
                                                {
                                                  banSystem.tempBan(loggedID!, true);
                                                  banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                  banSystem.updateUserCounter(loggedID!, CounterType.other, 0);
                                                  currentUser = (await SocialCubit.get(context).getCurrentUserData(loggedID!))!;
                                                  if (currentUser.numberOfBans! >= 5)
                                                  {
                                                    banSystem.updateUserState(loggedID!, true);
                                                    banSystem.userLogout(context);
                                                    navigateAndfFinish(context, SocialLoginScreen());
                                                  }
                                                }
                                                break;
                                              default:
                                                break;
                                            }
                                            banSystem.updateSumOfCounters(loggedID!, sum);
                                            SocialCubit.get(context)
                                                .sendMessage(
                                              receiverId: userModel!.uId!,
                                              dateTime: DateTime.now()
                                                  .toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              warning: true,
                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            if (sum >= 5)
                                              {
                                                banSystem.updateUserNumOfBans(loggedID!, currentUser.numberOfBans! + 1);
                                                banSystem.tempBan(loggedID!, true);
                                                banSystem.updateSumOfCounters(loggedID!, 0);
                                              }
                                            // Scroll to the last message
                                            //scrollDown();
                                          }
                                          else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(content: Text(
                                                  'Please enter some text or select an image.')),
                                            );
                                          }
                                        }
                                        else {
                                          if (messageController.text
                                              .isNotEmpty) {
                                            SocialCubit.get(context)
                                                .sendMessage(
                                              receiverId: userModel!.uId!,
                                              dateTime: DateTime.now()
                                                  .toString(),
                                              text: messageController.text,
                                              image: messageImg ?? '',
                                              warning: false,
                                            );
                                            messageController.clear();
                                            messageImg = null;
                                            // Scroll to the last message
                                            //0scrollDown();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(content: Text(
                                                  'Please enter some text or select an image.')),
                                            );
                                          }
                                        }
                                      }
                                      else
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                'Due to inappropriate behavior you are banned from sending messages')),
                                          );
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
              ),
            );

        },
      );
    },
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              warningText,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
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
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                    elevation: 0.0,
                    title: const Text('Image',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
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
}