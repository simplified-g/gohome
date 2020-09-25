import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/cityContent.dart';

class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        showSearch(context: context, delegate: DataSearch());
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Type your search here"),
              Icon(
                Icons.search,
                color: Color(0xFF79c942),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  List<String> results = List<String>();

  final recentResults = ['Lagos', 'Abuja'];

  @override
  List<Widget> buildActions(BuildContext context) {
    // build actions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the bar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    setSuggestions();
    // show some results based on selecion
    return CityContent(query, hideAppBar: true);
  }

  setSuggestions() async {
    if(query.isNotEmpty) {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      List<String> suggestions = shared_User.getStringList("suggestions");
      if (suggestions == null) {
        suggestions = List<String>();
      }
      if (!suggestions.contains(query)) {
        suggestions.insert(0, query);
      }
      shared_User.setStringList("suggestions", suggestions);
    }
  }

  getSuggestions() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    List<String> suggestions = shared_User.getStringList("suggestions");
    print(suggestions);
    if (suggestions != null) {
      results = suggestions;
    }
    shared_User.setStringList("suggestions", suggestions);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getSuggestions();
    // Show when someone searches for something
    final suggestionList = query.isEmpty
        ? results
        : results
            .where((p) => p.contains(query))
            .toList(); // to fix lowercase searches with or

    return ListView(children: [
      Container(
        padding: EdgeInsets.all(10),
        child: Text(
          "Search History",
          style: TextStyle(fontSize: 20),
        ),
      ),
      ...suggestionList
          .map((suggestion) => ListTile(
                title: InkWell(
                  onTap: () {
                    // showResults(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityContent(suggestion),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: suggestion.substring(0, suggestion.length),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: suggestion.substring(suggestion.length),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text("Are you sure you want to remove "
                                    "'$suggestion' from Search History")
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                deleteSuggestions(suggestion);
                                Navigator.of(context).pop();
                              },
                              color: Colors.red,
                              textColor: Colors.white,
                            ),
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ))
          .toList()
    ]);
  }

  deleteSuggestions(String query) async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    List<String> suggestions = shared_User.getStringList("suggestions");
    suggestions.remove(query);
    shared_User.setStringList("suggestions", suggestions);
    results.remove(query);

    String temp = this.query;
    this.query = '';
    this.query = temp;
  }
}
