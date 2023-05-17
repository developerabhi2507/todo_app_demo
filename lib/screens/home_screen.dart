import 'package:flutter/material.dart';
import 'package:todo_app_demo/screens/add_todo_screen.dart';

import '../models/add_todo_model.dart';
import '../utils/database_helper.dart';
import 'todo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Todo>> _todoListFuture;

  @override
  void initState() {
    super.initState();
    _todoListFuture = DatabaseHelper.instance.getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My ToDo List'),
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todoListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final todoList = snapshot.data!;
            return ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final todo = todoList[index];
                return ListTile(
                  title: Text('${todo.columnText}'),
                  subtitle: Text('${todo.columnTime}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDetailScreen(todo: todo),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load todos.'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTodoScreen(title: 'My Todo'),
            ),
          );
        },
        tooltip: 'Add a Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
