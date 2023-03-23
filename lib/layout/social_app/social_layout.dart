import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/modules/social_app/chats/chats_screen.dart';
import 'package:first_app/modules/social_app/social_login/cubit/cubit.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../modules/social_app/social_login/social_login_screen.dart';
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
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
          child: Scaffold(
            appBar:
            AppBar(
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
                IconButton(
                    onPressed:() async {
                      // FirebaseAuth.instance.signOut().then((value) {
                      //   SocialCubit.get(context).clearUserModel();
                      //   navigateAndfFinish(
                      //      context,
                      //      SocialLoginScreen(),
                      //   );
                      // });
                    },
                    icon: const Icon(Icons.logout)),

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
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        IconBroken.User,
                      ),
                    label: 'Contacts',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person_outlined,
                      ),
                    label: 'Profile',
                  ),
                ],
            ),
          ),
        );
      },
    );
  }
}
