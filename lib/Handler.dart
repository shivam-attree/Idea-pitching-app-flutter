import 'package:idea_pitching_app/ListItem.dart';
import 'package:idea_pitching_app/PostNewIdeas.dart';
import 'package:idea_pitching_app/Repository.dart';

import 'FilterInput.dart';
import 'Auth.dart';
import 'package:idea_pitching_app/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Handler extends StatefulWidget {
  Handler({
    @required this.auth, @required this.onSignOut
  });

  final BaseAuth auth;
  final VoidCallback onSignOut;
  @override
  State<StatefulWidget> createState() => new _MyAppState(auth: auth, onSignOut: onSignOut);

}

class _MyAppState extends State<Handler> {

  _MyAppState({this.auth, this.onSignOut});

  final BaseAuth auth;
  final VoidCallback onSignOut;

  Brightness brightness = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.indigo,
        accentColor: Colors.indigo[500],
        brightness: brightness,
      ),
      home: new MyHomePage(title: 'Real time ideas',auth: auth, onSignOut:onSignOut),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title,this.auth, this.onSignOut }) : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback onSignOut;
  @override
  _MyHomePageState createState() => new _MyHomePageState(auth: auth, onSignOut: onSignOut);
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState({
    this.auth,
    this.onSignOut,
  });

  final BaseAuth auth;
  final VoidCallback onSignOut;

  FocusNode focusNode;

  ScrollController controller = new ScrollController();

  final double loadMoreThreshold = 200.0;

  bool isLoading = false;

  Repository repository = new Repository();

  List<FilterItem> filter = [];

  bool showFastScrollUp = false;

  int allItemsCount = 0;
  int filteredItemsCount = 0;


  double bufferPosition = 0.0;
  bool scrollsUp = false;

  double showFastScrollThreshold = 200.0;

  double firstActivateThreshold = 1000.0;
  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();

    repository.load();

//    MaterialPageRoute.debugEnableFadingRoutes = true;


    controller.addListener(() {
      if(controller.offset > controller.position.maxScrollExtent - loadMoreThreshold) {
        _loadMore();
      }

      if(controller.position.userScrollDirection == ScrollDirection.forward && controller.offset > firstActivateThreshold) {
        //When switching from scrolling down to scrolling up
        if(!scrollsUp) {
          bufferPosition = controller.offset;
        }
        if(bufferPosition - controller.offset > showFastScrollThreshold) {
          setState(() {
            showFastScrollUp = true;
          });
        }
        scrollsUp = true;

      } else {
        scrollsUp = false;
        setState(() {
          showFastScrollUp = false;
        });
      }
    });
  }




  void _loadMore() {
    if(!isLoading) {
      setState(() {
        isLoading = true;
      });
      repository.load().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }


  @override
  void dispose() {
    focusNode.dispose();
    repository.dispose();
    controller.dispose();
    super.dispose();
  }



  void _scrollUp() {
    controller.animateTo(0.0, duration: const Duration(milliseconds: 900), curve: Curves.decelerate);
    setState(() {
      showFastScrollUp = false;
    });
  }

  void _onFilterSettingsChanged(List<FilterItem> items) {
    setState(() {
      filter = items;
    });
  }


  bool _shouldKeepItem(RedditPost post) {
    if(filter.isEmpty) return true;
    String regexString = filter.map((filterItem)=> filterItem.text).join("|");
    if(post.title.contains(new RegExp(regexString)) || post.selftext.contains(new RegExp(regexString))) {
      return true;
    }
    return false;
  }

//  List<RedditPost> _filter(List<RedditPost> posts) {
//    return posts.where(_shouldKeepItem).toList();
//  }
  List<RedditPost> _filter2(List<RedditPost> posts) {
    List<RedditPost> result = [];
    for(RedditPost post in posts) {
      if(_shouldKeepItem(post)) {
        result.add(post);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {

//    void _signOut() async {
//      try {
//        await auth.signOut();
//        onSignOut();
//      } catch (e) {
//        print(e);
//      }
//    }

    return new StreamBuilder<List<RedditPost>>(
      stream: repository.getPostStream(),
      builder: (BuildContext context, AsyncSnapshot<List<RedditPost>> snapshot) {
        allItemsCount = snapshot.data?.length ?? 0;
        List<RedditPost> items = _filter2(snapshot.data ?? const []);
        filteredItemsCount = items.length;
        return new Scaffold(
          appBar: new AppBar(
              title: new Text(widget.title),
              actions: <Widget>[
                new IconButton(icon: new Icon(Icons.add_to_home_screen), onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IdeasList(auth: auth,onSignOut: onSignOut,)));
                })
              ],
              bottom: new PreferredSize(
                  child: new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: new Align(
                        alignment: Alignment.centerLeft,
                        child: new Text("$allItemsCount/$filteredItemsCount", style: new TextStyle(color: Colors.white),)
                    ),
                  ),
                  preferredSize: const Size.fromHeight(5.0)
              )
          ),
          body: new Container(
            child: new FastScrollTop(
              visible: showFastScrollUp,
              onClick: _scrollUp,
              child: new RefreshIndicator(
                onRefresh: () async {
                  repository.reset();
                  return repository.load();
                },
                child: new CustomScrollView(
                  slivers: <Widget>[
                    new SliverToBoxAdapter(
                      child: new FilterInput(
                        onFilterSettingsChanged: _onFilterSettingsChanged,
                      ),
                    ),
                    new SliverList(delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                      return new ListItem(title: items[index].title, subtitle: items[index].selftext, onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
                          return new ListItemPage(
                            title: items[index].title,
                            subtitle: items[index].selftext,
                            source: items[index].permalink,
                          );
                        }), );
                      });
                    }, childCount: items != null ? items.length : 0)),
                    new SliverToBoxAdapter(
                      child: isLoading? new Center(child: new CircularProgressIndicator()) :new MaterialButton(child: new Text("load more"), onPressed: _loadMore,),
                    )
                  ],
                  controller: controller,
                  //   physics: new BouncyBouncingScrollPhysics(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}


class FastScrollTop extends StatefulWidget {

  final bool visible;

  final Widget child;

  final VoidCallback onClick;

  const FastScrollTop({Key key, this.visible, this.child, this.onClick}) : super(key: key);

  @override
  _FastScrollTOpState createState() => new _FastScrollTOpState();
}

class _FastScrollTOpState extends State<FastScrollTop> {

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).accentColor;
    return new Stack(
      children: <Widget>[
        widget.child,
        widget.visible ? new Positioned(
            top: 10.0,
            bottom:  null,
            left: 0.0,
            right: 0.0,
            child: new Center(
              child: new MaterialButton(
                onPressed: widget.onClick,
                color: color,
                child: new Text("Scroll up"),
              ),
            )
        ) : new SizedBox()
      ],
    );
  }
}
