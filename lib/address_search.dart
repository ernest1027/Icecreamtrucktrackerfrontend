import 'package:flutter/material.dart';
import 'place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  final sessionToken;
  late PlaceApiProvider apiClient;

  AddressSearch(this.sessionToken) {
    this.apiClient = PlaceApiProvider(sessionToken);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, new Suggestion("placeId", "description"));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(((snapshot.data as List)[index] as Suggestion)
                        .description),
                    onTap: () {
                      close(context,
                          (snapshot.data as List)[index] as Suggestion);
                    },
                  ),
                  itemCount: (snapshot.data as List).length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}
