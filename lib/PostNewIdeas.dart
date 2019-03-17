import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:idea_pitching_app/business/ListViewNote.dart';
import 'package:idea_pitching_app/Auth.dart';
import 'package:idea_pitching_app/entertainment/EListViewNote.dart';
import 'package:idea_pitching_app/investment/IListViewNote.dart';
import 'package:idea_pitching_app/sports/SListViewNote.dart';
import 'package:idea_pitching_app/technology/TListViewNote.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Pitch-in new ideas'),),
        body: IdeasList(),
      ),
    );
  }
}

class HomePage extends SliverPersistentHeaderDelegate {
  HomePage({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(minHeight, maxHeight);

  @override
  Widget build(BuildContext context,double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child,);
  }

  @override
  bool shouldRebuild(HomePage oldDelegate) {
    return maxHeight!= oldDelegate.maxHeight || minHeight!= oldDelegate.minHeight || child!= oldDelegate.child;
  }

}

class IdeasList extends StatelessWidget {
  IdeasList({
    this.auth,
    this.onSignOut,
  });

  final BaseAuth auth;
  final VoidCallback onSignOut;

  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: HomePage(minHeight: 60.0, maxHeight: 200.0, child: Container(
        color: Colors.white,
        child: Center(child: Text(headerText),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    void signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }
    }
    return CustomScrollView(
      slivers: <Widget>[
        makeHeader('Sections'),
        SliverFixedExtentList(
          itemExtent: 150.0,
          delegate: SliverChildListDelegate(
            [
              Container(color: Colors.lightBlue,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListViewNote()));
                }, child: new Text('Business'), ),
              ),),
              Container(color: Colors.lightBlue,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SListViewNote()));
                }, child: new Text('Sports'), ),
              ),),
              Container(color: Colors.lightBlue,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IListViewNote()));
                }, child: new Text('Investment'), ),
              ),),
              Container(color: Colors.lightBlue,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TListViewNote()));
                }, child: new Text('Technology'), ),
              ),),
              Container(color: Colors.lightBlue,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EListViewNote()));
                }, child: new Text('Entertainment'), ),
              ),),
              Container(color: Colors.black,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                    onPressed: signOut,
                    child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.white))
                ),
              ),)
            ],
          ),
        )
      ],
    );
  }

}
