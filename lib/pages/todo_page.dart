import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';

enum MenuItem { checkAll, uncheckAll, deleteAll }

class TodoPage extends StatefulWidget {
  final Todo todo;
  const TodoPage({super.key, required this.todo});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController textFieldAddItemController = TextEditingController();
  bool textFieldAddItemVisible = false;
  String? errorDuple;
  final keyAnimated = GlobalKey<AnimatedListState>();
  Item? itemSelect;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textFieldAddItemController.dispose();
    keyAnimated.currentState?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  resetTextFieldAddItem({bool visible = false}) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    setState(() {
      textFieldAddItemController.clear();
      textFieldAddItemVisible = visible;
      errorDuple = null;
      itemSelect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> todos = context.watch<TodoProvider>().todos;
    Todo todo = todos.firstWhere((to) => to.name == widget.todo.name);
    List<Item> items = todo.items;
    int itemsDone = items.where((item) => item.done == true).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(todo.name),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('$itemsDone/${items.length}'),
            ),
          ),
          PopupMenuButton<MenuItem>(
            onCanceled: () => resetTextFieldAddItem(),
            onSelected: (MenuItem item) {
              resetTextFieldAddItem();
              if (item == MenuItem.checkAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, true));
              } else if (item == MenuItem.uncheckAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, false));
              } else if (item == MenuItem.deleteAll) {
                deleteAll(context, todo);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
              const PopupMenuItem<MenuItem>(value: MenuItem.checkAll, child: Text('Check All')),
              const PopupMenuItem<MenuItem>(value: MenuItem.uncheckAll, child: Text('Uncheck All')),
              const PopupMenuItem<MenuItem>(
                  value: MenuItem.deleteAll, child: Text('Eliminar Ítems')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (textFieldAddItemVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() => errorDuple = null);
                },
                controller: textFieldAddItemController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal[50],
                  labelText: 'New Item',
                  errorText: errorDuple,
                  suffixIcon: IconButton(
                    onPressed: textFieldAddItemController.text.isEmpty
                        ? null
                        : () {
                            if (todo.items
                                .any((item) => item.name == textFieldAddItemController.text)) {
                              setState(() => errorDuple = 'Item duple');
                            } else {
                              addItem(context, todo, textFieldAddItemController.text);
                            }
                          },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          //if (items.isEmpty) const Text('Tarea sin ítems'),
          Expanded(
            child: AnimatedList(
              key: keyAnimated,
              controller: scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 80),
              initialItemCount: items.length,
              itemBuilder: (BuildContext context, int index, animation) {
                if (items.isEmpty) return const Text('');
                var item = items[index];
                return SlideTransition(
                  position: animation.drive(
                      Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
                          .chain(CurveTween(curve: Curves.ease))),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: itemSelect?.name == item.name
                          ? null
                          : item.done
                              ? Colors.black12
                              : null,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: ListTile(
                      enabled: !textFieldAddItemVisible,
                      onTap: () => toggleItem(context, todo, item),
                      selected: itemSelect?.name == item.name,
                      selectedTileColor: Colors.teal[50],
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (itemSelect?.name == item.name)
                            IconButton(
                              onPressed: () => removeItem(context, todo, item),
                              icon: const Icon(Icons.delete),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: item.done
                                ? const Icon(Icons.check_box)
                                : const Icon(Icons.check_box_outline_blank),
                          ),
                          IconButton(
                            onPressed: textFieldAddItemVisible
                                ? null
                                : () {
                                    if (itemSelect == null || itemSelect?.name != item.name) {
                                      resetTextFieldAddItem();
                                      setState(() => itemSelect = item);
                                    } else {
                                      ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                      setState(() => itemSelect = null);
                                    }
                                  },
                            icon: const Icon(Icons.more_vert),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => resetTextFieldAddItem(visible: !textFieldAddItemVisible),
        mini: true,
        backgroundColor: textFieldAddItemVisible ? Colors.red : Colors.teal,
        child: textFieldAddItemVisible ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
    );
  }

  addItem(BuildContext context, Todo todo, String name) {
    context.read<TodoProvider>().addItem(todo, Item(name: name));
    //Scrollable.ensureVisible();
    context.read<TodoProvider>().sortItems(todo);
    resetTextFieldAddItem();
    int indice = todo.items.indexWhere((item) => item.name == name);
    if (indice == -1) {
      indice = 0;
    }
    int position = todo.items.length - todo.items.where((it) => it.done == true).length;

    //scrollController.jumpTo(position.toDouble() * 60);
    // crollController.position.maxScrollExtent  // minScrollExtent // scrollController.initialScrollOffset,
    scrollController
        .animateTo(
          //indice * 50.toDouble(),
          position.toDouble() * 50,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        )
        .whenComplete(() => keyAnimated.currentState?.insertItem(
              indice,
              duration: const Duration(milliseconds: 500),
            ));
    //keyAnimated.currentState?.insertItem(indice, duration: const Duration(milliseconds: 500));
  }

  toggleItem(BuildContext context, Todo todo, Item item) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    setState(() => itemSelect = item);
    context.read<TodoProvider>().toggleItem(todo, item);
    Future.delayed(const Duration(milliseconds: 500), () {
      todo.items.sort((a, b) => a.done.toString().compareTo(b.done.toString()));
      context.read<TodoProvider>().sortItems(todo);
    });
    Future.delayed(const Duration(milliseconds: 1000), (() => setState(() => itemSelect = null)));
  }

  removeItem(BuildContext context, Todo todo, Item item) {
    int indice = todo.items.indexWhere((it) => it.name == item.name);
    keyAnimated.currentState?.removeItem(indice, (_, animation) {
      return SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: const Offset(1, 0),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeInOutBack))),
        child: ListTile(
          title: Text(item.name),
          tileColor: Colors.teal[50],
        ),
      );
    }, duration: const Duration(milliseconds: 500));
    context.read<TodoProvider>().removeItem(todo, item);
  }

  deleteAll(BuildContext context, Todo todo) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text('¿Eliminar todas los Ítems?'),
        leading: const Icon(Icons.delete_forever),
        actions: <Widget>[
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              //context.read<TodoProvider>().removeItemsTodo(todo);
              for (int i = todo.items.length - 1; i >= 0; i--) {
                await Future.delayed(const Duration(milliseconds: 500));
                if (!mounted) return;
                removeItem(context, todo, todo.items[i]);
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
