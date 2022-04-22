import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startup_namer/providers/favorites.dart';
import 'package:english_words/english_words.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    Widget dialogHandler(String _s) {
      return AlertDialog(
        title: const Text('Delete Suggestion'),
        content: Text('Are you sure you want to delete ${_s} from your saved suggestions?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return Consumer<Favorites>(
      builder: (context, favorites, child) {
        const _biggerFont = TextStyle(fontSize: 18); // NEW
        final tiles = favorites.favorites.map(
              (pair) {
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: ValueKey<WordPair>(pair),
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text("Delete Suggestion",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ], mainAxisAlignment: MainAxisAlignment.end),
                ),
              ),
              onDismissed: (direction) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text('Deletion is not implemented yet'),
                //   ),
                // );
                favorites.removeItemFromFavorites(pair);
              },
              confirmDismiss: (DismissDirection d) async {
                String? res = await showDialog(context: context,
                    builder: (BuildContext context) {
                      return dialogHandler(pair.asPascalCase);
                    });
                if (res == "OK") return true;
                return false;
              },
              child: Container(
                height: 60.0,
                // decoration: BoxDecoration(border: Border.all(width: 1.0)),
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    )
                  ],
                ),
              ),
            );
          },
        );


        final divided = tiles.isNotEmpty
            ? ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList()
            : <Widget>[];


        return Scaffold(
          // Add from here...
          appBar: AppBar(
            title: const Text('Startup Name Generator'),
          ),
          body: ListView(children: divided),
        ); // ... to here.}

      },
    );
  }
}
