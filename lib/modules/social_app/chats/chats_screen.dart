import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:Chatty/layout/social_app/cubit/cubit.dart';
import 'package:Chatty/layout/social_app/cubit/states.dart';
import 'package:Chatty/models/social_app/social_user_model.dart';
import 'package:Chatty/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:Chatty/shared/components/components.dart';
import 'package:Chatty/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print(loggedID);
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        return ConditionalBuilder(
              condition: SocialCubit.get(context).users.isNotEmpty,
              builder: (context) => ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context,index){
                  final user = SocialCubit.get(context).users[index];
                  if (user.uId == loggedID) {
                    return const SizedBox.shrink(); // exclude the logged in user
                  }
                  return buildChatItem(user,context);
                },
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
