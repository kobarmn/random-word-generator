import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// アプリ全体の状態を管理
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// アプリが機能するために必要となるデータを定義
class MyAppState extends ChangeNotifier {
  /* ランダム単語生成 */
  // var current = WordPair.random(); // <初期宣言> 出力される単語
  var current = FavoriteItem(pair: WordPair.random());

  void getNext() {
    current = FavoriteItem(pair: WordPair.random()); // 単語生成
    notifyListeners(); // 単語生成した旨を通知🔔
  }

  /* お気に入り単語登録 */
  var favorites = <FavoriteItem>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current); // 現在の単語を「お気に入りリスト」から<削除>
    } else {
      favorites.add(current); // 現在の単語を「お気に入りリスト」に <追加>
    }
    print(favorites);
    notifyListeners(); // 変更内容を通知
  }

  /* タグ機能追加 */
  void updateTag(WordTag newTag) {
    // すでに同じタグなら none に戻す（トグル機能）
    if (current.tag == newTag) {
      current.tag = WordTag.none;
    } else {
      current.tag = newTag;
    }
    notifyListeners(); // 変更内容を通知
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  // アプリの状態が変わった際に、buildメソッドは呼び出される。
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
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

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorite = appState.favorites;

    if (favorite.isEmpty) {
      return Center(
        child: Text('お気に入りリストに単語はありません'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var fav in favorite)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(fav.pair.asLowerCase),
            trailing: Text(fav.tag.name),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Appの状態を追跡する。
    var pair = appState.current;

    IconData HeartIcon;
    if (appState.favorites.contains(pair)) {
      HeartIcon = Icons.favorite;
    } else {
      HeartIcon = Icons.favorite_border;
    }

    IconData coolIcon =
        (appState.current.tag == WordTag.cool) ? Icons.star : Icons.star_border;

    IconData cuteIcon = (appState.current.tag == WordTag.cute)
        ? Icons.auto_awesome
        : Icons.auto_awesome_outlined;

    print(pair);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Bigcard(favitem: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* お気に入りボタン❤️*/
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(HeartIcon),
                label: Text('Like'),
              ),

              /* Coolボタン⭐️️*/
              ElevatedButton.icon(
                  onPressed: () {
                    appState.updateTag(WordTag.cool);
                  },
                  icon: Icon(coolIcon),
                  label: Text('Cool')),

              /* Cuteボタン⭐️️*/
              ElevatedButton.icon(
                  onPressed: () {
                    appState.updateTag(WordTag.cute);
                  },
                  icon: Icon(cuteIcon),
                  label: Text('Cute')),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          /* 次へボタン */
          ElevatedButton(
            onPressed: () {
              appState.getNext();
            },
            child: Text('Next'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 50),
            ),
          ),
        ],
      ),
    );
  }
}

class Bigcard extends StatelessWidget {
  const Bigcard({
    super.key,
    required this.favitem,
  });

  final FavoriteItem favitem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          favitem.pair.asLowerCase,
          style: style,
          semanticsLabel: "${favitem.pair.first} ${favitem.pair.second}",
        ),
      ),
    );
  }
}

// タグ管理
enum WordTag { none, cool, cute }

class FavoriteItem {
  final WordPair pair;
  WordTag tag; // 'Cool', 'Cute', 'None'

  FavoriteItem({required this.pair, this.tag = WordTag.none});
}
