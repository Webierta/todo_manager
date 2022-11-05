import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/tag.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../router/routes_const.dart';
import '../theme/app_color.dart';
import '../widgets/app_drawer.dart';
import '../widgets/nothing_bear.dart';

enum Menu { sortAZ, sortDone, sortDate, deleteAll }

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
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        autofocus: true,
        onChanged: (value) => setState(() => errorDuple = null),
        controller: textFieldAddController,
        decoration: InputDecoration(
          labelText: appLang.newTask,
          errorText: errorDuple,
          suffixIcon: IconButton(
            onPressed: textFieldAddController.text.isEmpty
                ? null
                : () {
                    if (todos.any((todo) => todo.name == textFieldAddController.text)) {
                      setState(() => errorDuple = appLang.repeTask);
                    } else {
                      addTodo(context, textFieldAddController.text, todos.length);
                    }
                  },
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
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
        title: filterTag == null ? const Text('To-Do') : Text(filterTag!.name),
        actions: [
          /* Center(
            child: Text('${countRatioItemsDone(todos)}/${todos.length}'),
          ), */
          InputChip(
            labelPadding: const EdgeInsets.symmetric(horizontal: 0),
            label: Text('${countRatioItemsDone(todos)}/${todos.length}'),
          ),
          IconButton(
            onPressed: () {
              resetTextField();
              setState(() => filterPriority = !filterPriority);
            },
            icon: Icon(Icons.stars, color: filterPriority ? Colors.amber : null),
          ),
          if (filterTag == null) ...[
            PopupMenuButton<Tag>(
              child: const Icon(Icons.label_outline),
              onCanceled: () => resetTextField(),
              onSelected: (Tag tag) {
                resetTextField();
                setState(() => filterTag = tag);
              },
              itemBuilder: (BuildContext context) {
                List<Tag> tags = [...Tag.values];
                tags.sort(((a, b) => appLang.tag(a.name).compareTo(appLang.tag(b.name))));
                return tags
                    .map((tag) => PopupMenuItem<Tag>(
                          value: tag,
                          child: Row(
                            children: [
                              Icon(Icons.label, color: AppColor.tagColors[Tag.values.indexOf(tag)]),
                              Text(appLang.tag(tag.name))
                            ],
                          ),
                        ))
                    .toList();
              },
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => filterTag = null),
              icon: const Icon(Icons.label_off_outlined),
            ),
          ],
          PopupMenuButton<Menu>(
            onCanceled: () => resetTextField(),
            onSelected: (Menu item) {
              resetTextField();
              if (item == Menu.sortAZ) {
                context.read<TodoProvider>().sortAZ();
              } else if (item == Menu.sortDone) {
                context.read<TodoProvider>().sortDone();
              } else if (item == Menu.sortDate) {
                context.read<TodoProvider>().sortDate();
              } else if (item == Menu.deleteAll) {
                BannerConfirmDelete(context: context).showBanner();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(value: Menu.sortAZ, child: Text(appLang.sortAZ)),
              PopupMenuItem<Menu>(value: Menu.sortDone, child: Text(appLang.sortDone)),
              PopupMenuItem<Menu>(value: Menu.sortDate, child: Text(appLang.sortDate)),
              const PopupMenuDivider(),
              PopupMenuItem<Menu>(value: Menu.deleteAll, child: Text(appLang.deleteAll)),
            ],
          ),
        ],
      ),
      body: todos.isEmpty && !textFieldAddVisible
          ? const NothingBear()
          : ReorderableListView.builder(
              shrinkWrap: true,
              scrollController: scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              header: header(context, todos),
              footer: todos.length > 10
                  ? IconButton(
                      onPressed: () {
                        if (scrollController.hasClients) {
                          scrollController.animateTo(
                            scrollController.initialScrollOffset,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
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
                //todo.ratioItemsDone = items.isEmpty ? 0 : items.length / itemsDone;
                todo.ratioItemsDone = items.isEmpty ? 0 : itemsDone / items.length;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  key: UniqueKey(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                          if (!filterPriority && !textFieldAddVisible && filterTag == null) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ReorderableDragStartListener(
                                index: index,
                                enabled: !filterPriority && !textFieldAddVisible,
                                child: const Icon(Icons.unfold_more),
                              ),
                            )
                          ],
                        ],
                      ),
                      ExpansionTile(
                        initiallyExpanded: todoSelect == todo && !textFieldAddVisible,
                        tilePadding: const EdgeInsets.only(left: 8, right: 4),
                        onExpansionChanged: ((value) {
                          //setState(() => textFieldAddVisible = false);
                          if (todoSelect == null || todoSelect?.name != todo.name) {
                            resetTextField();
                            setState(() => todoSelect = todo);
                          } else {
                            resetTextField();
                          }
                        }),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 2))
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                              setState(() => todoEdit = null);
                              context.go(todoPage, extra: todo);
                            },
                            icon: iconStatus(todo.ratioItemsDone),
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (items.isNotEmpty) ...[
                              Text('$itemsDone/${items.length}'),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: LinearProgressIndicator(value: itemsDone / items.length),
                                ),
                              ),
                              //Text('${(itemsDone / items.length) * 100}%'),
                              //Text('${(todo.ratioItemsDone * 100).toStringAsFixed(2).replaceAll(RegExp(r'([.]*00)(?!.*\d)'), '')}%'),
                              Text(todo.displayRatioPercentage()),
                            ] else ...[
                              Text(appLang.emptyTask)
                            ],
                          ],
                        ),
                        title: todoEdit?.name == todo.name && todoSelect?.name == todo.name
                            ? TextField(
                                autofocus: true,
                                onChanged: (value) => setState(() => errorDuple = null),
                                controller: textFieldEditController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: '${appLang.newName} ${todo.name}',
                                  errorText: errorDuple,
                                  suffixIcon: IconButton(
                                    onPressed: textFieldEditController.text.isEmpty
                                        ? null
                                        : () {
                                            if (todos.any((todo) =>
                                                todo.name == textFieldEditController.text)) {
                                              setState(() => errorDuple = appLang.repeTask);
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                  if (todoEdit == null || todoEdit!.name != todo.name) {
                                    textFieldEditController.text = todo.name;
                                    setState(() => todoEdit = todo);
                                  } else {
                                    textFieldEditController.clear();
                                    setState(() => todoEdit = null);
                                  }
                                  //textFieldEditController.clear();
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
                                  tags.sort(((a, b) =>
                                      appLang.tag(a.name).compareTo(appLang.tag(b.name))));
                                  return tags
                                      .map((tag) => PopupMenuItem<Tag>(
                                            value: tag,
                                            child: Row(children: [
                                              Icon(
                                                Icons.label,
                                                color: AppColor.tagColors[Tag.values.indexOf(tag)],
                                              ),
                                              Text(appLang.tag(tag.name))
                                            ]),
                                          ))
                                      .toList();
                                },
                              ),
                              IconButton(
                                onPressed: () async => await selectDate(context, todo),
                                icon: const Icon(Icons.today),
                              ),
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
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          InputChip(
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            avatar: Icon(Icons.label, color: todo.tag.color),
                            label: Text(appLang.tag(todo.tag.name)),
                          ),
                          if (todo.date != null)
                            InputChip(
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                              avatar: const Icon(Icons.today),
                              //label: Text(DateFormat.yMd().format(todo.date!)),
                              //label: Text(DateFormat('dd/MM/yy').format(todo.date!)),
                              label: Text(appLang.onDate(todo.date!)),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          }
          resetTextField(visible: !textFieldAddVisible);
        },
        mini: true,
        backgroundColor: textFieldAddVisible ? Colors.red : null,
        child: textFieldAddVisible ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
    );
  }

  /* int countRatioItemsDone(List<Todo> todos) {
    int count = 0;
    for (var todo in todos) {
      List<Item> items = todo.items;
      int itemsDone = items.where((item) => item.done == true).length;
      todo.ratioItemsDone = items.isEmpty ? 0 : items.length / itemsDone;
      if (todo.ratioItemsDone == 1) count++;
    }
    return count;
  } */

  int countRatioItemsDone(List<Todo> todos) {
    int count = 0;
    for (var todo in todos) {
      List<Item> items = todo.items;
      int itemsDone = items.where((item) => item.done == true).length;
      todo.ratioItemsDone = items.isEmpty ? 0 : itemsDone / items.length;
      if (todo.ratioItemsDone == 1) count++;
    }
    return count;
  }

  Icon iconStatus(double ratio) {
    if (ratio == 0) return const Icon(Icons.playlist_add);
    if (ratio == 1) return const Icon(Icons.task_alt);
    return const Icon(Icons.warning_amber);
  }

  addTodo(BuildContext context, String input, int length) async {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();

    if (length != 0) {
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    }
    Todo newTodo = Todo(name: input);
    if (!mounted) return;
    context.read<TodoProvider>().add(newTodo);
    if (filterTag != null) {
      context.read<TodoProvider>().updateTag(newTodo, filterTag!);
    }
    if (filterPriority) {
      context.read<TodoProvider>().updatePrirority(newTodo, filterPriority);
    }
    resetTextField();
  }

  renameTodo(BuildContext context, Todo todo, String newName) {
    context.read<TodoProvider>().rename(todo, newName);
    setState(() {
      textFieldEditController.clear();
      todoEdit = null;
    });
  }

  selectDate(BuildContext context, Todo todo) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (!mounted) return;
    context.read<TodoProvider>().updateDate(todo, picked);
  }
}

class BannerConfirmDelete {
  final BuildContext context;
  final Todo? todo;
  const BannerConfirmDelete({required this.context, this.todo});

  showBanner() {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    String content = todo != null ? appLang.deleteTask : appLang.deleteAllTasks;
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
            child: Text(appLang.cancel),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              todo != null
                  ? context.read<TodoProvider>().remove(todo!)
                  : context.read<TodoProvider>().removeAll();
              context.go('/');
            },
            child: Text(appLang.confirm),
          ),
        ],
      ),
    );
  }
}
