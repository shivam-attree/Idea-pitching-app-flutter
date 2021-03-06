import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ListItem extends StatelessWidget {


  final String title;
  final String subtitle;

  final VoidCallback onTap;

  const ListItem({Key key, this.title, this.subtitle, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleTextStyle = new TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,

    );

    TextStyle subtitleTextStyle = new TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w300

    );

    return new Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: new RoundedRectangleBorder(),
      elevation: 0.5,
      child: new InkWell(
        onTap: onTap,
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(title, style: titleTextStyle,),
              subtitle.isNotEmpty? new Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: new Text(subtitle, style: subtitleTextStyle, overflow: TextOverflow.ellipsis, maxLines: 3,),
              )
                  : new SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

class ListItemPage extends StatelessWidget {


  final String title;
  final String subtitle;
  final String source;

  const ListItemPage({Key key, this.title, this.subtitle, this.source}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextStyle titleTextStyle = const TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,

    );
    TextStyle subtitleTextStyle = const TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w300

    );

    Color buttonColor = Theme.of(context).accentColor;
    TextStyle buttonTextStyle = const TextStyle(
        color: Colors.white
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Item"),
      ),
      body: new ListView(
        padding: const EdgeInsets.all(12.0),
        children: <Widget>[
          new Text(title, style: titleTextStyle,),
          new Divider(),
          new MarkdownBody(data: subtitle),
          subtitle.isNotEmpty? new Divider(): const SizedBox(),
          //  new MarkdownBody(data: "[source](https://www.reddit.com$source)", onTapLink: _onLinkTapped,),
          new Row(
            children: <Widget>[
              new Expanded(
                  flex: 1,
                  child: new Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
