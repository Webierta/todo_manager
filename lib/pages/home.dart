import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';

enum Menu { sortAZ, sortDone, deleteAll }

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController textFieldAddController = TextEditingController();
  bool textFieldAddVisible = false;
  String? errorDuple;
  TextEditingController textFieldEditController = TextEditingController();
  bool filterPriority = false;
  Todo? todoSelect;
  Todo? todoEdit;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<TodoProvider>(context, listen: false).refreshTodosBox();
    });
    super.initState();
  }

  @override
  void dispose() {
    textFieldAddController.dispose();
    textFieldEditController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  resetTextField({bool visible = false}) {
    setState(() {
      textFieldAddController.clear();
      textFieldAddVisible = visible;
      errorDuple = null;
      todoSelect = null;
      todoEdit = null;
    });
  }

  Widget? header(BuildContext context, List<Todo> todos, Todo? todo) {
    if (!textFieldAddVisible && todoEdit == null) return null;
    TextEditingController controller = textFieldAddController;
    String labelText = 'New Task';
    IconData iconData = Icons.add;
    if (todo != null) {
      controller = textFieldEditController;
      labelText = 'New Name for ${todo.name}';
      iconData = Icons.published_with_changes;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        autofocus: true,
        onChanged: (value) => setState(() => errorDuple = null),
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.teal[50],
          labelText: labelText,
          errorText: errorDuple,
          suffixIcon: IconButton(
            onPressed: controller.text.isEmpty
                ? null
                : () {
                    if (todos.any((todo) => todo.name == controller.text)) {
                      setState(() => errorDuple = 'Task duple');
                    } else {
                      if (todo == null) {
                        addTodo(context, textFieldAddController.text, todos.length);
                      } else {
                        renameTodo(context, todo, textFieldEditController.text);
                      }
                    }
                  },
            icon: Icon(iconData),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> todos = context.watch<TodoProvider>().todos;
    if (filterPriority) {
      todos = todos.where((todo) => todo.priority == true).toList();
    }

    return Scaffold(
      //drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('To-Do Manager'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('${countRatioItemsDone(todos)}/${todos.length}'),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                resetTextField();
                filterPriority = !filterPriority;
              });
            },
            icon: Icon(Icons.stars, color: filterPriority ? Colors.amber : null),
          ),
          PopupMenuButton<Menu>(
            onCanceled: () {
              resetTextField();
              ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            },
            onSelected: (Menu item) {
              resetTextField();
              ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              if (item == Menu.sortAZ) {
                context.read<TodoProvider>().sortAZ();
              } else if (item == Menu.sortDone) {
                context.read<TodoProvider>().sortDone();
              } else if (item == Menu.deleteAll) {
                deleteAll(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              const PopupMenuItem<Menu>(value: Menu.sortAZ, child: Text('Odenar A-Z')),
              const PopupMenuItem<Menu>(value: Menu.sortDone, child: Text('Ordenar Pendiente')),
              const PopupMenuItem<Menu>(value: Menu.deleteAll, child: Text('Eliminar Todo')),
            ],
          ),
        ],
      ),
      body: ReorderableListView.builder(
        shrinkWrap: true,
        scrollController: scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        header: header(context, todos, todoEdit),
        footer: todos.length > 10
            ? IconButton(
                onPressed: () {
                  scrollController.animateTo(
                    scrollController.initialScrollOffset,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                icon: const Icon(Icons.arrow_upward),
              )
            : null,
        buildDefaultDragHandles: false,
        itemCount: todos.length,
        onReorder: (oldIndex, newIndex) {
          resetTextField();
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Todo todoMove = todos.removeAt(oldIndex);
            todos.insert(newIndex, todoMove);
          });
          context.read<TodoProvider>().sortOnReorder(todos);
        },
        itemBuilder: (BuildContext context, int index) {
          var todo = todos[index];
          List<Item> items = todo.items;
          int itemsDone = items.where((item) => item.done == true).length;
          todo.ratioItemsDone = items.isEmpty ? 0 : items.length / itemsDone;
          return Container(
            key: UniqueKey(),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.3),
              ),
            ),
            child: ListTile(
              enabled: !textFieldAddVisible,
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                setState(() => todoEdit = null);
                context.go('/todo_page', extra: todo);
              },
              selected: todoSelect?.name == todo.name,
              selectedTileColor: Colors.teal[50],
              title: Text(todo.name),
              subtitle: Text('$itemsDone/${items.length}'),
              leading: iconStatus(todo.ratioItemsDone),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: todoSelect?.name == todo.name,
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                        if (todoEdit == null || todoEdit!.name != todo.name) {
                          setState(() => todoEdit = todo);
                        } else {
                          setState(() => todoEdit = null);
                        }
                        textFieldEditController.clear();
                        setState(() => errorDuple = null);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  Visibility(
                    visible: todoSelect?.name == todo.name,
                    child: IconButton(
                      onPressed: () {
                        resetTextField();
                        removeTodo(context, todo);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                  IconButton(
                    onPressed: textFieldAddVisible
                        ? null
                        : () => context.read<TodoProvider>().updatePrirority(todo, !todo.priority),
                    icon: Icon(
                      Icons.star,
                      color: todo.priority ? Colors.amber : Colors.grey,
                    ),
                  ),
                  if (!filterPriority && !textFieldAddVisible)
                    ReorderableDragStartListener(
                      index: index,
                      enabled: !filterPriority && !textFieldAddVisible,
                      child: const Icon(Icons.unfold_more),
                    ),
                  IconButton(
                    onPressed: textFieldAddVisible
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                            setState(() => todoEdit = null);
                            if (todoSelect == null || todoSelect?.name != todo.name) {
                              resetTextField();
                              setState(() => todoSelect = todo);
                            } else {
                              setState(() => todoSelect = null);
                            }
                          },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
          resetTextField(visible: !textFieldAddVisible);
        },
        backgroundColor: textFieldAddVisible ? Colors.red : Colors.teal,
        child: textFieldAddVisible ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
    );
  }

  int countRatioItemsDone(List<Todo> todos) {
    int count = 0;
    for (var todo in todos) {
      List<Item> items = todo.items;
      int itemsDone = items.where((item) => item.done == true).length;
      todo.ratioItemsDone = items.isEmpty ? 0 : items.length / itemsDone;
      if (todo.ratioItemsDone == 1) count++;
    }
    return count;
  }

  Icon iconStatus(double ratio) {
    if (ratio == 0) return const Icon(Icons.playlist_add);
    if (ratio == 1) return const Icon(Icons.task_alt, color: Colors.green);
    return const Icon(Icons.warning_amber, color: Colors.red);
  }

  addTodo(BuildContext context, String input, int length) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    if (length != 0) {
      scrollController
          .animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          )
          .whenComplete(() => context.read<TodoProvider>().add(Todo(name: input)));
    } else {
      context.read<TodoProvider>().add(Todo(name: input));
    }
    resetTextField();
  }

  renameTodo(BuildContext context, Todo todo, String newName) {
    context.read<TodoProvider>().rename(todo, newName);
    setState(() {
      textFieldEditController.clear();
      //todoNameEdit = '';
      todoEdit = null;
    });
  }

  removeTodo(BuildContext context, Todo todo) {
    context.read<TodoProvider>().remove(todo);
  }

  deleteAll(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: const Text('¿Eliminar todas las Tareas?'),
        leading: const Icon(Icons.delete_forever),
        actions: <Widget>[
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              context.read<TodoProvider>().removeAll();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
