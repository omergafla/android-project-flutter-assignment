import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:startup_namer/providers/auth.dart';
import 'package:startup_namer/providers/favorites.dart';
import 'package:firebase_storage/firebase_storage.dart';


class StartupNames extends StatefulWidget {
  const StartupNames({Key? key}) : super(key: key);

  @override
  _StartupNamesState createState() => _StartupNamesState();
}

class _StartupNamesState extends State<StartupNames> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _biggerFont = const TextStyle(fontSize: 18); // NEW
  final _suggestions = generateWordPairs().take(10).toList(); // NEW
  final snapsheet_controller = new SnappingSheetController();
  final _snapping_positions = const [
    SnappingPosition.factor(
      positionFactor: 0.0,
      snappingCurve: Curves.easeInOut,
      snappingDuration: Duration(seconds: 1),
      grabbingContentOffset: GrabbingContentOffset.top,
    ),
    SnappingPosition.factor(
      snappingCurve: Curves.easeInOut,
      snappingDuration: Duration(milliseconds: 1000),
      positionFactor: 0.2,
    ),
  ]; // final _biggerFont = const TextStyle(fontSize: 18); // NEW

  Future<String> _getImageUrl(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(builder: (context, auth, _) {
      return Scaffold(
          // Add from here...
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Startup Name Generator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.pushNamed(context, '/favorites');
                },
                tooltip: 'Saved Suggestions',
              ),
              IconButton(
                icon: auth.status == Status.Authenticated
                    ? const Icon(Icons.exit_to_app)
                    : const Icon(Icons.login),
                onPressed: () async {
                  // Navigate to the second screen using a named route.
                  if (auth.status == Status.Authenticated) {
                    await auth.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully logged out"),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
                tooltip: 'Login',
              ),
            ],
          ),
          body: //_buildSuggestions(),
              auth.status == Status.Authenticated
                  ? SnappingSheet(
                      // TODO: Add your content that is placed
                      // behind the sheet. (Can be left empty)
                      child: _buildSuggestions(),
                      controller: snapsheet_controller,
                      grabbingHeight: 50,
                      snappingPositions: _snapping_positions,
                      // TODO: Add your grabbing widget here,
                      grabbing: InkWell(
                          onTap: () {
                            setState(() {
                              snapsheet_controller.currentSnappingPosition ==
                                      _snapping_positions[0]
                                  ? snapsheet_controller
                                      .snapToPosition(_snapping_positions[1])
                                  : snapsheet_controller
                                      .snapToPosition(_snapping_positions[0]);
                            });
                          },
                          child: Container(
                            color: Colors.grey,
                            alignment: Alignment.center,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                        "Welcome back, ${auth.user?.email.toString()}"),
                                    const Icon(Icons.expand_less)
                                  ],
                                )),
                          )),
                      sheetBelow: SnappingSheetContent(
                        draggable: true,
                        // TODO: Add your sheet content here
                        child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0,0,0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  auth.avatarUrl == ""
                                      ? const CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.deepPurple,
                                          child: Icon(Icons.camera_alt),
                                        )
                                      : CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(auth.avatarUrl),
                                        ),
                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${auth.user?.email.toString()}", style: const TextStyle(fontSize: 18.0)),
                                        MaterialButton(
                                          child: const Text("Change Avatar"),
                                          height: 25,
                                          color: Colors.deepPurple,
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform
                                                .pickFiles(type: FileType.image);

                                            if (result != null) {
                                              File file = File(result.files.single.path!);
                                              String? uid = auth.user?.uid;
                                              String fileName = uid == null ? "" : uid.toString();
                                              String _imageUrl = await _getImageUrl(file, fileName);
                                              await auth.setAvatarUrl(_imageUrl);
                                              setState(() {});
                                            } else {
                                              const snackBar = SnackBar(
                                                content: Text('No image selected'),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          },
                                        )
                                      ]))
                                ],
                              ),
                            )),
                      ),
                    )
                  : _buildSuggestions()); // ... to here.
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    // var favorites = Provider.of<Favorites>(context);
    // var _saved =favorites.favorites;
    return Consumer<Favorites>(builder: (context, _favorites, _) {
      final favorites = _favorites.favorites;
      bool inFavorites = favorites.contains(pair);
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          inFavorites ? Icons.star : Icons.star_border,
          color: inFavorites ? Colors.deepPurple : null,
          semanticLabel: inFavorites ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          _favorites.toggleFavorite(pair);
        }, // ... to here.
      );
    });
  }
}
