import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/layout/social_app/cubit/cubit.dart';
import 'package:first_app/modules/social_app/settings/settings_screen.dart';
import 'package:first_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:first_app/shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:first_app/modules/social_app/social_login/cubit/states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../main.dart';
import '../../../../shared/components/components.dart';

class SocialLoginCubit extends Cubit<SocialLoginStates>
{
  SocialLoginCubit() : super(SocialLoginInitialState());

  static SocialLoginCubit get(context) => BlocProvider.of(context);
 //  void userLogin({
 //    required String email,
 //    required String password,
 //  })
 // {
 //   emit(SocialLoginLoadingState());
 //   FirebaseAuth.instance.signInWithEmailAndPassword(
 //       email: email,
 //       password: password,
 //   ).then((value)
 //   {
 //     print(value.user!.email);
 //     print(value.user!.uid);
 //     emit(SocialLoginSuccessState(value.user!.uid));
 //   })
 //       .catchError((error)
 //   {
 //     emit(SocialLoginErrorState(error.toString()));
 //   });
 // }
  void userLogin({
    required String email,
    required String password,
    required BuildContext context,
  })
  {
    emit(SocialLoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value)
    {
      print(value.user!.email);
      print(value.user!.uid);

      //LOGOUT DEPENDENT
      // loggedID = value.user!.uid;
      // SocialCubit.get(context).getUserData();
      emit(SocialLoginSuccessState(value.user!.uid));
    })
        .catchError((error)
    {
      emit(SocialLoginErrorState(error.toString()));
    });
  }



  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  void changePasswordVisibilty(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined ;
    emit(SocialChangePasswordVisibilityState());
  }

}