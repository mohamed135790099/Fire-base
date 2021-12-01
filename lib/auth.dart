
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier{
   String? _token;
   DateTime? _expiryDate;
   String? _userID;

 bool get isAuth{
    return token !=null;
  }
  String? get token{
    if(_expiryDate !=null &&_expiryDate!.isAfter(DateTime.now())&& _token !=null)
    {
      return _token;
    }return null;
  }
  Future<void>_authenticate(String email,String password,String urlSegment)async{
    var url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCZOwWi1czlJUaUkJsLq73vjhQ6bdPLr-o');
    try{
      final res= await http.post(url,body:json.encode({
        'email':email,
        'password':password,
        'returnSecureToken':true,
      }));
      final resDate=json.decode(res.body);
      if(resDate['error']!=null){
        throw "${resDate['error']['message']}";
      }
      _token=resDate['idToken'];
      _userID=resDate['localId'];
      _expiryDate=DateTime.now().add(Duration(seconds:int.parse(resDate['expiresIn'])));
      print(_token);
      print(_userID);
      print(_expiryDate);
      notifyListeners();
      final _prefers=await SharedPreferences.getInstance();
      final userData=json.encode({
        'token':_token,
        'userId':_userID,
        'expiryDate':_expiryDate!.toIso8601String(),
      });
      _prefers.setString('userData', userData);
    }catch(e){throw e;}
  }
  Future <bool>tryAutoLogin()async{
    final _prefers= await SharedPreferences.getInstance();
    if(!_prefers.containsKey('userData')){
      return false;
     }
    final extractUserData=json.decode(_prefers.getString('userData')!) as Map<String,Object>;
    final expiryData=DateTime.parse('${extractUserData['expiryDate']}');

    if(expiryData.isBefore(DateTime.now())){
      return false;
    }
    _token=extractUserData['token'] as String;
    _userID=extractUserData['userId'] as String;
    _expiryDate=extractUserData['expiryDate'] as DateTime;
    print('/////////////////////////////////');
    print(_token);
    print(_userID);
    print(_expiryDate);
    notifyListeners();
    return true;

  }


  Future<void>sigUp(String email,String password)async{
    return await _authenticate(email, password, 'signUp');
  }
  Future<void> login(String email,String password)async{
    return await _authenticate(email, password, 'signInWithPassword');
  }
  void logout(){

    _token='';
    _expiryDate=null;
    _userID='';
    notifyListeners();
  }
}