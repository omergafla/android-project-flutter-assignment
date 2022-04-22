import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'favorites.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class Auth with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  String _avatarUrl = "";
  final _storage = FirebaseStorage.instance;

  Auth.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  String get avatarUrl => _avatarUrl;

  setAvatarUrl(String url) {
    _avatarUrl = url;
    notifyListeners();
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      UserCredential res =  await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await Favorites.instance.backUpToCloud();
      await Favorites.instance.setUserFavoritesUponLogin();
      return res;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await Favorites.instance.backUpToCloud();
      await Favorites.instance.setUserFavoritesUponLogin();
      await _getAvatarURL();
      return true;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _avatarUrl = "";
    _status = Status.Unauthenticated;
    await Favorites.instance.clear();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  // void changeImg(String url){
  //   _avatarUrl = url;
  //   notifyListeners();
  // }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _avatarUrl = "";
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<void> _getAvatarURL() async {
    try {
      _avatarUrl = await _storage.ref("images").child(user!.uid).getDownloadURL();
      notifyListeners();
    } catch (e) {
      _avatarUrl = "";
      notifyListeners();
    }
  }
}