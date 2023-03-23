import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:first_app/shared/components/components.dart';
import 'package:first_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../layout/social_app/cubit/states.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        var userModel = SocialCubit.get(context).userModel;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children:
            [
              Container(
                height: 190.0,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Container(
                        height: 140.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                              4.0,),
                            topRight: Radius.circular(4.0,
                            ),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              userModel!.cover ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 64.0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundImage: NetworkImage(
                         '${userModel!.image}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                '${userModel.name}',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${userModel.bio}',
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: ()
                        {
                          navigateTo(context, EditProfileScreen());
                        },
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(

                              ),
                            ),
                            SizedBox(
                              width:20.0,
                            ),
                            Icon(IconBroken.Edit),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
