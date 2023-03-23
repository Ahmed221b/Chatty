import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/models/social_app/social_user_model.dart';
import 'package:first_app/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:first_app/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        return RefreshIndicator(
          onRefresh: () async{
              // SocialCubit.get(context).users.clear();
              // SocialCubit.get(context).getUsers();
          },
          child: ConditionalBuilder(
            condition:SocialCubit.get(context).users.length >= 0,
            builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context,index) => buildChatItem(SocialCubit.get(context).users[index],context),
              separatorBuilder: (context,index) => myDivider(),
              itemCount: SocialCubit.get(context).users.length,
            ),
            fallback: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildChatItem(SocialUserModel model,context) => InkWell(
    onTap: ()
    {
      navigateTo(context, ChatDetailsScreen(
        userModel: model,
      ),);
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
            backgroundImage:
            NetworkImage('${model.image}'),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Text(
            '${model.name}',
            style: const TextStyle(
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}
