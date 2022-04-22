// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'auth.dart';


class Favorites extends ChangeNotifier {
  List<WordPair> _favorites = [];
  final FirebaseFirestore _firestore =  FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Favorites._privateConstructor();

  static final Favorites instance =
  Favorites._privateConstructor();


  List<WordPair> get favorites => _favorites;


  toggleFavorite(WordPair _wordPair){
    if (_favorites.contains(_wordPair)){
      removeItemFromFavorites(_wordPair);
    }
    else{
      addItemToFavorites(_wordPair);
    }
  }

  addItemToFavorites(WordPair _wordPair) {
    if (!_favorites.contains(_wordPair)) {
      _favorites.add(_wordPair);
      storeUserFavorites();
      notifyListeners();
    }
  }

  removeItemFromFavorites(WordPair _wordPair) {
    if (_favorites.contains(_wordPair)) {
      _favorites.remove(_wordPair);
      storeUserFavorites();
      notifyListeners();
    }
  }

  void storeUserFavorites(){
    if(auth.currentUser?.uid != null){
      _firestore.collection('usersFavorites').doc(auth.currentUser?.uid).update({
        'favorites': _favorites.map((_wordPair) => _wordPair.asPascalCase).toList(),
      });
    }
  }

  WordPair toWordPair(String wordpair){
    var words = wordpair.split(RegExp(r"(?<=[a-z])(?=[A-Z])"));
    return WordPair(words[0], words[1]);
  }

  Future setUserFavoritesUponLogin() async {
    await _firestore
        .collection('usersFavorites')
        .doc(auth.currentUser?.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists == false) {
        await _firestore.collection('usersFavorites').doc(auth.currentUser?.uid).set({'favorites': _favorites.map((_wordPair) => _wordPair.asPascalCase).toList() });
      }
      else{
        _favorites = snapshot.data()!["favorites"].map<WordPair>((wordPairString) => toWordPair(wordPairString)).toList();
      }
      notifyListeners();
    });

  }

  Future clear() async {
    _favorites = [];
    notifyListeners();
  }

  Future backUpToCloud() async {
    _firestore
        .collection('usersFavorites')
        .doc(auth.currentUser?.uid)
        .update({'favorites': FieldValue.arrayUnion(_favorites.map((_wordPair) => _wordPair.asPascalCase).toList())});
    notifyListeners();
  }

}