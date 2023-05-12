import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../layout/social_app/cubit/states.dart';

class ProfileView extends StatelessWidget {
  final SocialUserModel? userModel;
  const ProfileView({Key? key, this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<SocialCubit, SocialStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var userModel = SocialCubit.get(context).userModel;
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            width: double.infinity,
                            height: 300.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('${userModel!.image}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
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
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(userModel!.cover ?? ''),
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
                            backgroundImage: NetworkImage('${userModel!.image}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  '${userModel?.name}',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${userModel?.bio}',
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          );
        },
      ),
    );
  }

}
