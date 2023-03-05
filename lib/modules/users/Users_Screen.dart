
import 'package:flutter/material.dart';

import '../../models/user/user_model.dart';
class UsersScreen extends StatelessWidget {
  List<UserModel> users = [
    UserModel(
        id: 1,
        name: 'Omar Sherif',
        phone: '01003246582',
    ),
    UserModel(
      id: 2,
      name: 'Amr Sherif',
      phone: '01005156582',
    ),
    UserModel(
      id: 3,
      name: 'Malek Sherif',
      phone: '01003126582',
    ),
    UserModel(
      id: 4,
      name: 'Malika Sherif',
      phone: '01003245682',
    ),
    UserModel(
      id: 5,
      name: 'Salem Sherif',
      phone: '01003258682',
    ),
    UserModel(
      id: 6,
      name: 'Sayed Sherif',
      phone: '01003688582',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         'Users',
        ),
      ),
      body: ListView.separated(
          itemBuilder: (Context,Index)=>BuildUserItem(users[Index]),
          separatorBuilder: (Context,Index)=> Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[300],
          ),
          itemCount: users.length),
    );
  }
  Widget BuildUserItem(UserModel user) => Padding (
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 25.0,
          child: Text(
            '${user.id}',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.name}',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${user.phone}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

