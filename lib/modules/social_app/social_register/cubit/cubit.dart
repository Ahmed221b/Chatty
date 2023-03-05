import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/models/social_app/social_user_model.dart';
import 'package:first_app/modules/social_app/social_register/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:first_app/modules/social_app/social_login/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialRegisterCubit extends Cubit<SocialRegisterStates>
{
  SocialRegisterCubit() : super(SocialRegisterInitialState());

  static SocialRegisterCubit get(context) => BlocProvider.of(context);
  void userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
   emit(SocialRegisterLoadingState());
   FirebaseAuth.instance.createUserWithEmailAndPassword(
       email: email,
       password: password,
   ).then((value) {
     userCreate(
         uId: value.user!.uid,
         phone: phone,
         email: email,
         name: name,
     );
   }).catchError((error){
     print(error.toString());
     emit(SocialRegisterErrorState(error.toString()));
   });
 }
  void userCreate({
    required String name,
    required String email,
    required String phone,
    required String uId,
  })
  {
    SocialUserModel model = SocialUserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      bio: 'Write your bio.....',
      cover: 'https://img.freepik.com/free-photo/close-up-young-successful-man-smiling-camera-standing-casual-outfit-against-blue-background_1258-66609.jpg?w=996&t=st=1676499092~exp=1676499692~hmac=5d4f12cb876a133d021d0e08eb9d60cdd7daec9eff61f1cae0507775392e8689',
      image: 'https://img.freepik.com/free-photo/close-up-young-successful-man-smiling-camera-standing-casual-outfit-against-blue-background_1258-66609.jpg?w=996&t=st=1676499092~exp=1676499692~hmac=5d4f12cb876a133d021d0e08eb9d60cdd7daec9eff61f1cae0507775392e8689',
      isEmailVerified: false,
    );

    FirebaseFirestore.instance.collection('users').doc(uId).set(model.toMap())
        .then(
            (value)
        {
          emit(SocialCreateUserSuccessState());
        })
        .catchError((error)
        {
          emit(SocialCreateUserErrorState(error.toString()));
        });
  }


  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  void changePasswordVisibility(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined ;
    emit(SocialRegisterChangePasswordVisibilityState());
  }

}