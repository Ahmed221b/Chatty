import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/modules/social_app/chats/chats_screen.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/components/components.dart';

class SocialLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){
        // if (state is SocialGetUserSuccessState)
        //   {
        //     navigateTo(context, ChatsScreen());
        //   }
      },
      builder: (context,state){
        var cubit = SocialCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(
                cubit.titles[cubit.currentIndex]
            ),
            actions: [
              IconButton(
                  onPressed: (){},
                  icon: const Icon(IconBroken.Notification),
              ),
              IconButton(
                  onPressed: (){},
                  icon: const Icon(IconBroken.Search),
              ),
            ],
          ),
          body: cubit.Screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeBottomNav(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Chat,
                    ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.User,
                    ),
                  label: 'User',
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Setting,
                    ),
                  label: 'Settings',
                ),
              ],
          ),
        );
      },
    );
  }
}
