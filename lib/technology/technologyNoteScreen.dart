import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:idea_pitching_app/model/note.dart';

class technologyNoteScreen extends StatefulWidget {
  final Note note;
  technologyNoteScreen(this.note);

  @override
  State<StatefulWidget> createState() => new technologyCommentsNoteScreenState();
}

final notesReference = FirebaseDatabase.instance.reference().child('technology');

class technologyCommentsNoteScreenState extends State<technologyNoteScreen> {
  TextEditingController _commentsController;

  @override
  void initState() {
    super.initState();

    _commentsController = new TextEditingController(text: widget.note.comments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(labelText: 'Comments'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.note.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.note.id != null) {
                  notesReference.child(widget.note.id).set({
                    'comments': _commentsController.text,
                  }).then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  notesReference.push().set({
                    'comments': _commentsController.text,
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}