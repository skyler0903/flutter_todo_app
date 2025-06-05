import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<TodoData>(
      create: (context) => TodoData(),
      builder: (context, child) => const TodoApp(),
    ),
  );
}

class TodoData extends ChangeNotifier {
  List<TodoItem> todos = [
    TodoItem(text: 'Learn Flutter'),
    TodoItem(text: 'Build a Todo App'),
    TodoItem(text: 'Profit!'),
  ];

  List<TodoItem> completedTodos = [];

  void addTodo(String text, BuildContext context) {
    todos.add(TodoItem(text: text));
    notifyListeners();
    _showSnackBar(context, 'Todo added');
  }

  void toggleTodo(TodoItem todo, BuildContext context) {
    todo.isDone = !todo.isDone;
    if (todo.isDone) {
      todos.remove(todo);
      completedTodos.add(todo);
    } else {
      completedTodos.remove(todo);
      todos.add(todo);
    }
    notifyListeners();
  }

  void deleteTodo(TodoItem todo, BuildContext context) {
    if (todo.isDone) {
      completedTodos.remove(todo);
    } else {
      todos.remove(todo);
    }
    notifyListeners();
    _showSnackBar(context, 'Todo deleted');
  }

  void updateTodo(TodoItem todo, String newText, BuildContext context) {
    todo.text = newText;
    notifyListeners();
    _showSnackBar(context, 'Todo updated');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class TodoItem {
  TodoItem({required this.text, this.isDone = false});

  String text;
  bool isDone;
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _displayAddDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add a todo item',
            style: TextStyle(color: Colors.deepPurple),
          ),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
              hintText: 'Enter your todo',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
            cursorColor: Colors.deepPurple,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'ADD',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Provider.of<TodoData>(
                  context,
                  listen: false,
                ).addTodo(_textFieldController.text, context);
                Navigator.of(context).pop();
                _textFieldController.clear();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }

  Future<void> _displayEditDialog(BuildContext context, TodoItem todo) async {
    final TextEditingController editController = TextEditingController(
      text: todo.text,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit todo item',
            style: TextStyle(color: Colors.deepPurple),
          ),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Enter your todo',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
            cursorColor: Colors.deepPurple,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'SAVE',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Provider.of<TodoData>(
                  context,
                  listen: false,
                ).updateTodo(todo, editController.text, context);
                Navigator.of(context).pop();
                editController.clear();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.deepPurple],
          ),
        ),
        child: Consumer<TodoData>(
          builder: (context, todoData, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: todoData.todos.length,
                    itemBuilder: (context, index) {
                      final todo = todoData.todos[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Dismissible(
                          key: Key(todo.text),
                          onDismissed: (direction) {
                            Provider.of<TodoData>(
                              context,
                              listen: false,
                            ).deleteTodo(todo, context);
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              todo.text,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurple.shade800,
                                decoration: todo.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              value: todo.isDone,
                              activeColor: Colors.deepPurple,
                              onChanged: (bool? value) {
                                todoData.toggleTodo(todo, context);
                              },
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _displayEditDialog(context, todo),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    Provider.of<TodoData>(
                                      context,
                                      listen: false,
                                    ).deleteTodo(todo, context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: todoData.completedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = todoData.completedTodos[index];
                      return Opacity(
                        opacity: 0.5,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Dismissible(
                            key: Key(todo.text),
                            onDismissed: (direction) {
                              Provider.of<TodoData>(
                                context,
                                listen: false,
                              ).deleteTodo(todo, context);
                            },
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                todo.text,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.deepPurple.shade800,
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              leading: Checkbox(
                                value: todo.isDone,
                                activeColor: Colors.deepPurple,
                                onChanged: (bool? value) {
                                  todoData.toggleTodo(todo, context);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _displayEditDialog(context, todo),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      Provider.of<TodoData>(
                                        context,
                                        listen: false,
                                      ).deleteTodo(todo, context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayAddDialog(context),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
