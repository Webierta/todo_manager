/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/tag.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../widgets/drawer_app.dart';

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
  Tag? filterTag;
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
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    setState(() {
      textFieldAddController.clear();
      textFieldAddVisible = visible;
      errorDuple = null;
      todoSelect = null;
      todoEdit = null;
    });
  }

  Widget? header(BuildContext context, List<Todo> todos) {
    //if (!textFieldAddVisible && todoEdit == null) return null;
    if (!textFieldAddVisible) return null;

    TextEditingController controller = textFieldAddController;
    String labelText = 'New Task';
    IconData iconData = Icons.add;
    /* if (todo != null) {
      controller = textFieldEditController;
      labelText = 'New Name for ${todo.name}';
      iconData = Icons.published_with_changes;
    } */
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
                      addTodo(context, textFieldAddController.text, todos.length);
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
    if (filterTag != null) {
      todos = todos.where((todo) => todo.tag == filterTag).toList();
    }

    return Scaffold(
      drawer: const DrawerApp(),
      appBar: AppBar(
        title: filterTag == null ? const Text('To-Do') : Text('To-Do: ${filterTag!.name}'),
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
                resetTextField();
                setState(() => filterPriority = !filterPriority);
              });
            },
            icon: Icon(Icons.stars, color: filterPriority ? Colors.amber : null),
          ),
          if (filterTag == null)
            PopupMenuButton<Tag>(
              child: const Icon(Icons.label_outline),
              onCanceled: () => resetTextField(),
              onSelected: (Tag tag) {
                resetTextField();
                setState(() => filterTag = tag);
              },
              itemBuilder: (BuildContext context) => Tag.values
                  .map((tag) => PopupMenuItem<Tag>(
                        value: tag,
                        child: Text(tag.name),
                      ))
                  .toList(),
            )
          else
            IconButton(
              onPressed: () => setState(() => filterTag = null),
              icon: const Icon(Icons.label_off_outlined),
            ),
          PopupMenuButton<Menu>(
            onCanceled: () => resetTextField(),
            onSelected: (Menu item) {
              resetTextField();
              if (item == Menu.sortAZ) {
                context.read<TodoProvider>().sortAZ();
              } else if (item == Menu.sortDone) {
                context.read<TodoProvider>().sortDone();
              } else if (item == Menu.deleteAll) {
                BannerConfirmDelete(context: context).showBanner();
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
        //header: header(context, todos, todoEdit),
        header: header(context, todos),
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
          return SingleChildScrollView(
            key: UniqueKey(),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: const EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  if (!textFieldAddVisible) {
                    if (todoSelect == null || todoSelect?.name != todo.name) {
                      resetTextField();
                      setState(() => todoSelect = todo);
                    } else {
                      resetTextField();
                    }
                  }
                },
                children: <ExpansionPanel>[
                  ExpansionPanel(
                    isExpanded: todo.name == todoSelect?.name,
                    backgroundColor:
                        todoSelect?.name == todo.name ? Colors.teal[50] : Colors.transparent,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        enabled: !textFieldAddVisible,
                        onTap: () {
                          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                          setState(() => todoEdit = null);
                          context.go('/todo_page', extra: todo);
                        },
                        selected: todoSelect?.name == todo.name,
                        selectedTileColor: Colors.teal[50],
                        focusColor: Colors.teal[50],
                        horizontalTitleGap: 8,
                        minVerticalPadding: 0,
                        contentPadding: const EdgeInsets.fromLTRB(10, 16, 0, 10),
                        title: Text(todo.name),
                        /* subtitle: Wrap(
                          spacing: 0,
                          runSpacing: 0,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            InputChip(
                              labelPadding: const EdgeInsets.all(0),
                              avatar: const Icon(Icons.label_outline),
                              label: Text(todo.tag.name),
                            ),
                            const InputChip(
                              labelPadding: EdgeInsets.all(0),
                              label: Text('22/08/22'),
                            ),
                          ],
                        ), */
                        subtitle: IntrinsicHeight(
                          child: Row(
                            //mainAxisSize: MainAxisSize.max,
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: InputChip(
                                    labelPadding: const EdgeInsets.all(0),
                                    avatar: Icon(
                                      Icons.label,
                                      color: todo.tag.color,
                                    ),
                                    label: Text(todo.tag.name),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: InputChip(
                                    labelPadding: EdgeInsets.all(0),
                                    //avatar: Icon(Icons.today),
                                    label: Text('22/08/22'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            iconStatus(todo.ratioItemsDone),
                            Text('$itemsDone/${items.length}')
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: textFieldAddVisible
                                  ? null
                                  : () => context
                                      .read<TodoProvider>()
                                      .updatePrirority(todo, !todo.priority),
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
                          ],
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (todoEdit?.name == todo.name)
                            Flexible(
                              child: TextField(
                                autofocus: true,
                                onChanged: (value) => setState(() => errorDuple = null),
                                controller: textFieldEditController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.teal[50],
                                  labelText: 'New Name for ${todo.name}',
                                  errorText: errorDuple,
                                  suffixIcon: IconButton(
                                    onPressed: textFieldEditController.text.isEmpty
                                        ? null
                                        : () {
                                            if (todos.any((todo) =>
                                                todo.name == textFieldEditController.text)) {
                                              setState(() => errorDuple = 'Task duple');
                                            } else {
                                              renameTodo(
                                                  context, todo, textFieldEditController.text);
                                            }
                                          },
                                    icon: const Icon(Icons.published_with_changes),
                                  ),
                                ),
                              ),
                            ),
                          IconButton(
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
                          PopupMenuButton<Tag>(
                            child: const Icon(Icons.label_outline),
                            //onCanceled: () => resetTextField(),
                            onSelected: (Tag tag) =>
                                context.read<TodoProvider>().updateTag(todo, tag),
                            itemBuilder: (BuildContext context) => Tag.values
                                .map((tag) => PopupMenuItem<Tag>(
                                      value: tag,
                                      child: Text(tag.name),
                                    ))
                                .toList(),
                          ),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.today)),
                          IconButton(
                            onPressed: () async {
                              resetTextField();
                              BannerConfirmDelete(context: context, todo: todo).showBanner();
                              setState(() => todoSelect = todo);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
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
          //scrollController.jumpTo(0);
          scrollController.animateTo(0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
          resetTextField(visible: !textFieldAddVisible);
        },
        mini: true,
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
}

class BannerConfirmDelete {
  final BuildContext context;
  final Todo? todo;
  const BannerConfirmDelete({required this.context, this.todo});

  showBanner() {
    String content = todo != null ? '¿Eliminar esta tarea?' : '¿Eliminar todas las Tareas?';
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: Text(content),
        leading: const Icon(Icons.delete_forever),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              todo != null
                  ? context.read<TodoProvider>().remove(todo!)
                  : context.read<TodoProvider>().removeAll();
              context.go('/');
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/tag.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../theme/app_color.dart';
import '../widgets/app_drawer.dart';

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
  Tag? filterTag;
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
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    setState(() {
      textFieldAddController.clear();
      textFieldAddVisible = visible;
      errorDuple = null;
      todoSelect = null;
      todoEdit = null;
    });
  }

  Widget? header(BuildContext context, List<Todo> todos) {
    //if (!textFieldAddVisible && todoEdit == null) return null;
    if (!textFieldAddVisible) return null;

    TextEditingController controller = textFieldAddController;
    String labelText = 'New Task';
    IconData iconData = Icons.add;
    /* if (todo != null) {
      controller = textFieldEditController;
      labelText = 'New Name for ${todo.name}';
      iconData = Icons.published_with_changes;
    } */
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        autofocus: true,
        onChanged: (value) => setState(() => errorDuple = null),
        controller: controller,
        decoration: InputDecoration(
          //filled: true,
          //fillColor: Colors.teal[50],
          labelText: labelText,
          errorText: errorDuple,
          suffixIcon: IconButton(
            onPressed: controller.text.isEmpty
                ? null
                : () {
                    if (todos.any((todo) => todo.name == controller.text)) {
                      setState(() => errorDuple = 'Task duple');
                    } else {
                      addTodo(context, textFieldAddController.text, todos.length);
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
    if (filterTag != null) {
      todos = todos.where((todo) => todo.tag == filterTag).toList();
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: filterTag == null ? const Text('To-Do') : Text('To-Do: ${filterTag!.name}'),
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
                resetTextField();
                setState(() => filterPriority = !filterPriority);
              });
            },
            icon: Icon(Icons.stars, color: filterPriority ? Colors.amber : null),
          ),
          if (filterTag == null)
            PopupMenuButton<Tag>(
              child: const Icon(Icons.label_outline),
              onCanceled: () => resetTextField(),
              onSelected: (Tag tag) {
                resetTextField();
                setState(() => filterTag = tag);
              },
              itemBuilder: (BuildContext context) {
                List<Tag> tags = [...Tag.values];
                tags.sort(((a, b) => a.name.compareTo(b.name)));
                return tags
                    .map((tag) => PopupMenuItem<Tag>(
                          value: tag,
                          child: Row(
                            children: [
                              Icon(Icons.label, color: AppColor.tagColors[Tag.values.indexOf(tag)]),
                              Text(tag.name),
                            ],
                          ),
                        ))
                    .toList();
              },
            )
          else
            IconButton(
              onPressed: () => setState(() => filterTag = null),
              icon: const Icon(Icons.label_off_outlined),
            ),
          PopupMenuButton<Menu>(
            onCanceled: () => resetTextField(),
            onSelected: (Menu item) {
              resetTextField();
              if (item == Menu.sortAZ) {
                context.read<TodoProvider>().sortAZ();
              } else if (item == Menu.sortDone) {
                context.read<TodoProvider>().sortDone();
              } else if (item == Menu.deleteAll) {
                BannerConfirmDelete(context: context).showBanner();
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
        //header: header(context, todos, todoEdit),
        header: header(context, todos),
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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            key: UniqueKey(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                        setState(() => todoEdit = null);
                        context.go('/todo_page', extra: todo);
                      },
                      icon: iconStatus(todo.ratioItemsDone),
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        initiallyExpanded: todoSelect == todo && !textFieldAddVisible,
                        tilePadding: const EdgeInsets.only(left: 16, right: 8),
                        //backgroundColor: Colors.teal[50],
                        onExpansionChanged: ((value) {
                          //setState(() => textFieldAddVisible = false);
                          if (todoSelect == null || todoSelect?.name != todo.name) {
                            resetTextField();
                            setState(() => todoSelect = todo);
                          } else {
                            resetTextField();
                          }
                        }),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              if (items.isNotEmpty) ...[
                                Text('$itemsDone/${items.length}'),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: LinearProgressIndicator(
                                      value: itemsDone / items.length,
                                      //minHeight: 1,
                                    ),
                                  ),
                                )
                              ] else ...[
                                const Text('Empty task')
                              ],
                            ],
                          ),
                        ),
                        title: todoEdit?.name == todo.name && todoSelect?.name == todo.name
                            ? TextField(
                                autofocus: true,
                                onChanged: (value) => setState(() => errorDuple = null),
                                controller: textFieldEditController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  //filled: true,
                                  //fillColor: Colors.teal[50],
                                  labelText: 'New Name for ${todo.name}',
                                  errorText: errorDuple,
                                  suffixIcon: IconButton(
                                    onPressed: textFieldEditController.text.isEmpty
                                        ? null
                                        : () {
                                            if (todos.any((todo) =>
                                                todo.name == textFieldEditController.text)) {
                                              setState(() => errorDuple = 'Task duple');
                                            } else {
                                              renameTodo(
                                                  context, todo, textFieldEditController.text);
                                            }
                                          },
                                    icon: const Icon(Icons.published_with_changes),
                                  ),
                                ),
                              )
                            : Text(
                                todo.name,
                                style: Theme.of(context).typography.white.headlineSmall,
                              ),
                        //textColor: Theme.of(context).expansionTileTheme.textColor,
                        //textColor: Colors.red,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
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
                              PopupMenuButton<Tag>(
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.label_outline),
                                ),
                                //onCanceled: () => resetTextField(),
                                onSelected: (Tag tag) =>
                                    context.read<TodoProvider>().updateTag(todo, tag),
                                itemBuilder: (BuildContext context) {
                                  List<Tag> tags = [...Tag.values];
                                  tags.sort(((a, b) => a.name.compareTo(b.name)));
                                  return tags
                                      .map((tag) => PopupMenuItem<Tag>(
                                            value: tag,
                                            child: Row(
                                              children: [
                                                Icon(Icons.label,
                                                    color: AppColor
                                                        .tagColors[Tag.values.indexOf(tag)]),
                                                Text(tag.name),
                                              ],
                                            ),
                                          ))
                                      .toList();
                                },
                              ),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.today)),
                              IconButton(
                                onPressed: () async {
                                  resetTextField();
                                  BannerConfirmDelete(context: context, todo: todo).showBanner();
                                  setState(() => todoSelect = todo);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Container(
                              //padding: const EdgeInsets.only(left: 16),
                              width: 140,
                              alignment: Alignment.centerLeft,
                              child: InputChip(
                                avatar: Icon(Icons.label, color: todo.tag.color),
                                label: Text(todo.tag.name),
                              ),
                            ),
                            const SizedBox(
                              width: 120,
                              child: InputChip(
                                avatar: Icon(Icons.today),
                                label: Text('22/08//22'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: textFieldAddVisible
                            ? null
                            : () =>
                                context.read<TodoProvider>().updatePrirority(todo, !todo.priority),
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
          //scrollController.jumpTo(0);
          scrollController.animateTo(0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
          resetTextField(visible: !textFieldAddVisible);
        },
        mini: true,
        backgroundColor: textFieldAddVisible ? Colors.red : null,
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
    if (ratio == 1) return const Icon(Icons.task_alt);
    return const Icon(Icons.warning_amber);
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
}

class BannerConfirmDelete {
  final BuildContext context;
  final Todo? todo;
  const BannerConfirmDelete({required this.context, this.todo});

  showBanner() {
    String content = todo != null ? '¿Eliminar esta tarea?' : '¿Eliminar todas las Tareas?';
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: Text(content),
        leading: const Icon(Icons.delete_forever),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              todo != null
                  ? context.read<TodoProvider>().remove(todo!)
                  : context.read<TodoProvider>().removeAll();
              context.go('/');
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
