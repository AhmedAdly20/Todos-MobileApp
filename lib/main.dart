import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todosapp/todo.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.orange,
      ),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Firestore _firestore = Firestore.instance;

  List todos = [];
  String input = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  title: Text('Add New Todo'),
                  content: TextField(
                    onChanged: (value) {
                      input = value;
                    },
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        addTodo(Todo(
                          tTitle: input,
                        ));
                        Navigator.pop(context);
                      },
                      child: Text('ADD'),
                    )
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: loadTodos(),
          // ignore: missing_return
          builder: (context, snapshot) {
            List<Todo> ourTodos = [];
            if (!snapshot.hasData) {
              return Center(child: Text('Loading..'),);
            }
            else{
              for (var doc in snapshot.data.documents) {
                var data = doc.data;
                ourTodos.add(Todo(
                  pId: doc.documentID,
                  tTitle: data["todoTitle"],
                ));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: ourTodos.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    onDismissed: (context) {
                      deleteTodo(ourTodos[index].pId);
                    },
                    key: Key(ourTodos[index].pId),
                    child: Card(
                      elevation: 4.0,
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(ourTodos[index].tTitle),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.check_box,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              deleteTodo(ourTodos[index].pId);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  Stream<QuerySnapshot> loadTodos() {
    return _firestore.collection("todos").snapshots();
  }

  addTodo(Todo todo) {
    _firestore.collection("todos").add({"todoTitle": todo.tTitle});
  }

  deleteTodo(documentId) {
    _firestore.collection("todos").document(documentId).delete();
  }
}
