import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:first_app/shared/components/components.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/social_app/social_user_model.dart';

class ImageUploaded extends StatelessWidget {
  SocialUserModel? userModel;
  String? message1 = '';
  var imageLabel ;
  ImageUploaded({super.key,this.userModel,});


  Future<String> predictimage(String imageUrl) async {
    final endpointUrl = 'http://192.168.1.32:5000/image?imageUrl=$imageUrl';

    final response = await http.get(Uri.parse(endpointUrl));
    if (response.statusCode == 200) {
      final result = json.decode(response.body)['prediction'];
      return result;
    } else {
      throw Exception('Failed to load prediction');
    }
  }


  @override
  Widget build(BuildContext context) {
    SocialCubit.get(context).getMessages(receiverId: userModel!.uId!,);
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Theme(
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
              title: const Text(
                'Image',
              ),
            ),
            body: ConditionalBuilder(
              condition: state is SocialUploadMessageImageSuccessState && messageImg != '',
              builder: (context) => Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Card(
                          borderOnForeground: true,
                          child: Image.network(
                            messageImg ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: ()
                      async{
                        final encodedUrl = Uri.encodeComponent(messageImg!);
                        imageLabel = await predictimage(encodedUrl);
                        if (imageLabel != 'not_cyberbullying')
                          {
                            if (messageImg != null)
                            {
                              SocialCubit.get(context).sendMessage(
                                receiverId: userModel!.uId!,
                                dateTime: DateTime.now().toString(),
                                text: message1!,
                                image: messageImg ?? '',
                                warning: true,
                              );
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
                            if (messageImg != null)
                            {
                              SocialCubit.get(context).sendMessage(
                                receiverId: userModel!.uId!,
                                dateTime: DateTime.now().toString(),
                                text: message1!,
                                image: messageImg ?? '',
                                warning: false,
                              );
                              messageImg = null;
                              // Scroll to the last message
                              //0scrollDown();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter some text or select an image.')),
                              );
                            }

                          }

                        Navigator.pop(context);
                      },
                      child: Icon(IconBroken.Send),
                    ),
                  ),
                ],
              ),
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }
}
