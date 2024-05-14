import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_project/services/firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController noteController = TextEditingController();

  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: noteController,
          onChanged: (value) {
            noteController.text = value;
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (docID == null) {
                  FirestoreService().addNote(noteController.text);
                  noteController.clear();
                  Navigator.pop(context);
                } else {
                  FirestoreService().updateNote(docID, noteController.text);
                  noteController.clear();
                  Navigator.pop(context);
                }
              },
              child: docID == null ? Text('Add Note') : Text('Update Note'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFDF0D5),
      appBar: AppBar(
        backgroundColor: Color(0xff780000),
        title: Text(
          'To Do ahhh',
          style: TextStyle(color: Color(0xffFDF0D5)),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // dynamic test = notesList[index].data()['note'];
                // print('This is the $test');

                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Color(0xff003049))),
                          onPressed: () => openNoteBox(docID),
                          child: Text(
                            'Update',
                            style: TextStyle(color: Color(0xffFDF0D5)),
                          ),
                        ),
                        IconButton(
                            onPressed: () =>
                                FirestoreService().deleteNote(docID),
                            icon: Icon(
                              Icons.delete,
                              color: Color(0xff780000),
                            ))
                      ],
                    ));
              },
            );
          } else {
            return Text('no task');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff003049),
        onPressed: () => openNoteBox(null),
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
          color: Color(0xffFDF0D5),
        ),
      ),
    );
  }
}
