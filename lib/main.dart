import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 1, 161, 253)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      bool isTablet = MediaQuery.of(context).size.width >= 600;
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                minWidth: isTablet ? 72 : 56,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ...
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorites yet.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 50.0, bottom:20.0,right:20.0,left:20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have ${appState.favorites.length} favorites:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: appState.favorites.length,
                itemBuilder: (context, index) {
                  var pair = appState.favorites[index];
                  return ListTile(
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: pair.first,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: pair.second,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        appState.favorites.remove(pair);
                        appState.notifyListeners();
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Text(
              "Username Generator",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: BigCard(key: ValueKey(pair), pair: pair),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 200.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 350) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        icon: Icon(icon),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(160, 80),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        label: Text('Like', style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          appState.getNext();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(160, 80),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Text('Next', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        icon: Icon(icon),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(160, 80),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        label: Text('Like', style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          appState.getNext();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(160, 80),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Text('Next', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 20.0, // Add shadow with elevation
      shadowColor: Colors.black54, // Optional: Customize shadow color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: pair.first,
                style: style,
              ),
              TextSpan(
                text: pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
