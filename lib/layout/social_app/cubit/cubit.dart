import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:first_app/layout/social_app/cubit/states.dart';
import 'package:first_app/models/social_app/message_model.dart';
import 'package:first_app/models/social_app/social_user_model.dart';
import 'package:first_app/modules/social_app/chats/chats_screen.dart';
import 'package:first_app/modules/social_app/settings/settings_screen.dart';
import 'package:first_app/modules/social_app/users/users_screen.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SocialCubit extends Cubit<SocialStates>{
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);
  SocialUserModel? userModel;
  void getUserData(){
    emit(SocialGetUserLoadingState());

    FirebaseFirestore.instance.collection('users').doc(uId).get()
        .then((value) {
          userModel = SocialUserModel.fromJson(value.data()!);
          emit(SocialGetUserSuccessState());
    })
        .catchError((error){
          print(error.toString());
          emit(SocialGetUserErrorState(error.toString()));
    });
  }

  bool isWarning = false;
  int currentIndex = 0;
  List<Widget> Screens = [
    ChatsScreen(),
    UsersScreen(),
    SettingsScreen(),
  ];
  List<String> titles = [
    'Chats',
    'Contacts',
    'Profile',
  ];

  void changeWarningVariable(bool val)
  {
    isWarning = !val;
  }

  void changeBottomNav(int index){

    currentIndex = index;

    emit(SocialChangeBottomNavState());
  }

  File? profileImage;
  var picker =ImagePicker();

  Future<void> getProfileImage() async
  {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      profileImage = File(pickedFile.path);
      print(pickedFile.path);
      emit(SocialProfilePickedImageSuccessState());
    }
    else{
      print('No image selected');
      emit(SocialProfilePickedImageErrorState());
    }
  }


  File? messageImage;
  Future<void> getMessageImage() async
  {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      messageImage = File(pickedFile.path);
      uploadMessageImage();
      // emit(SocialMessagePickedImageSuccessState());
    }
    else{
      print('No image selected');
      //emit(SocialMessagePickedImageErrorState());
    }

  }


  File? coverImage;
  Future<void> getCoverImage() async
  {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if(pickedFile != null){
      coverImage = File(pickedFile.path);
      emit(SocialCoverPickedImageSuccessState());
    }
    else{
      print('No image selected');
      emit(SocialCoverPickedImageErrorState());
    }
  }
  void uploadMessageImage()
  {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(messageImage!.path).pathSegments.last}')
        .putFile(messageImage!)
        .then((value){
      value.ref.getDownloadURL().then((value)
      {
        print(value.toString());
        messageImg = value;
        print(messageImg);
        emit(SocialUploadMessageImageSuccessState());
      }).catchError((error){
        emit(SocialUploadMessageImageErrorState());
      });
    }).catchError((error){
      emit(SocialUploadMessageImageErrorState());
    });
  }


  void uploadProfileImage({
  required String name,
  required String phone,
  required String bio,
  })
  {
    emit(SocialUserUpdateLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value){
          value.ref.getDownloadURL().then((value)
          {
            print(value);
            updateUser(
                name: name,
                phone: phone,
                bio: bio,
                image: value,
            );
          }).catchError((error){
            emit(SocialUploadProfileImageErrorState());
          });
         }).catchError((error){
      emit(SocialUploadProfileImageErrorState());
    });
  }



  void uploadCoverImage({
  required String name,
  required String phone,
  required String bio,
  })
  {
    emit(SocialUserUpdateLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((value){
      value.ref.getDownloadURL().then((value)
      {
        print(value);
        updateUser(
          name: name,
          phone: phone,
          bio: bio,
          cover: value,
        );
      }).catchError((error){
        emit(SocialUploadCoverImageErrorState());
      });
    }).catchError((error){
      emit(SocialUploadCoverImageErrorState());
    });
  }


  void updateUser({
    required String name,
    required String phone,
    required String bio,
    String? cover,
    String? image,
  })
  {
    emit(SocialUserUpdateLoadingState());
    SocialUserModel model = SocialUserModel(
      name: name,
      email: userModel!.email,
      uId: userModel!.uId,
      phone: phone,
      bio: bio,
      image: image??userModel!.image,
      cover: cover??userModel!.cover,
      isEmailVerified: false,
    );

    FirebaseFirestore
        .instance
        .collection('users')
        .doc(userModel!.uId)
        .update(model.toMap())
        .then((value)
    {
      getUserData();
    })
        .catchError((error){
      emit(SocialUserUpdateErrorState());
    });
  }

  List<SocialUserModel> users = [];

  void getUsers ()
  {

    FirebaseFirestore.instance.collection('users').get().then((value) {
      value.docs.forEach((element) {
        if(element.data()['uId'] != userModel!.uId) {
          users.add(SocialUserModel.fromJson(element.data()));
        }
      });
      emit(SocialGetAllUsersSuccessState());
    }).catchError((error){
      print(error.toString());
      emit(SocialGetAllUsersErrorState(error.toString()));
    });
  }

  void sendMessage({
    required String receiverId,
    required String dateTime,
    required String text,
    required String image,
    required bool warning
  })
  {
    MessageModel model = MessageModel(
      receiverId: receiverId,
      senderId: userModel!.uId,
      dateTime: dateTime,
      text: text,
      image: image,
      isBullying: warning,
    );
    FirebaseFirestore.instance
    .collection('users')
    .doc(userModel!.uId)
    .collection('chats')
    .doc(receiverId)
    .collection('messages')
    .add(model.toMap())
    .then((value){
      emit(SocialSendMessageSuccessState());
    })
    .catchError((error){
      emit(SocialSendMessageErrorState());
    });


    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .collection('messages')
        .add(model.toMap())
        .then((value){
      emit(SocialSendMessageSuccessState());
    })
        .catchError((error){
      emit(SocialSendMessageErrorState());
    });


  }

  List<MessageModel> messages = [];

  void getMessages({
    required String receiverId,
    }){
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
    .orderBy('dateTime')
        .snapshots()
        .listen((event) {
          messages = [];
          event.docs.forEach((element)
          {
            messages.add(MessageModel.fromJson(element.data()));
          });
          emit(SocialGetMessagesSuccessState());
    });
  }


}