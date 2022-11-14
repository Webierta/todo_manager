import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/menus.dart' show Menu;
import '../models/tag.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../router/routes_const.dart';
import '../theme/app_color.dart';
import '../widgets/app_drawer.dart';
import '../widgets/nothing_bear.dart';
import '../widgets/pop_menu.dart';
import '../widgets/proxy_decorator.dart';

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
  Todo? todoRename;
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
      todoRename = null;
      textFieldEditController.clear();
    });
  }

  Widget? header(BuildContext context, List<Todo> todos) {
    if (!textFieldAddVisible) return null;
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return TextField(
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

    /* bool buttonInactive(Todo todo) {
      if (textFieldAddVisible) return true;
      if (todoSelect == null) return false;
      return todoSelect?.name != todo.name;
    } */

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: filterTag == null ? const Text('To-Do') : Text(filterTag!.name),
        actions: [
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
              onPressed: () => resetTextField(),
              icon: const Icon(Icons.label_off_outlined),
            ),
          ],
          PopupMenuButton<Menu>(
            onCanceled: () => resetTextField(),
            onSelected: (Menu item) {
              if (item == Menu.sortAZ) {
                resetTextField();
                context.read<TodoProvider>().sortAZ();
              } else if (item == Menu.sortDone) {
                resetTextField();
                context.read<TodoProvider>().sortDone();
              } else if (item == Menu.sortDate) {
                resetTextField();
                context.read<TodoProvider>().sortDate();
              } else if (item == Menu.export) {
                if (todoSelect != null) {
                  exportTarea(context, todoSelect!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appLang.exportNullTodoSelect)),
                  );
                }
                resetTextField();
              } else if (item == Menu.import) {
                resetTextField();
                importTarea(context);
              } else if (item == Menu.deleteAll) {
                resetTextField();
                BannerConfirmDelete(context: context).showBanner();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopMenu.buildItem(
                value: Menu.sortAZ,
                iconData: Icons.sort_by_alpha,
                text: appLang.sortAZ,
              ),
              PopMenu.buildItem(
                value: Menu.sortDone,
                iconData: Icons.rule,
                text: appLang.sortDone,
              ),
              PopMenu.buildItem(
                value: Menu.sortDate,
                iconData: Icons.today,
                text: appLang.sortDate,
              ),
              const PopupMenuDivider(),
              PopMenu.buildItem(
                value: Menu.export,
                iconData: Icons.file_download,
                text: appLang.exportTask,
              ),
              PopMenu.buildItem(
                value: Menu.import,
                iconData: Icons.file_upload,
                text: appLang.importTask,
              ),
              const PopupMenuDivider(),
              PopMenu.buildItem(
                value: Menu.deleteAll,
                iconData: Icons.delete_forever,
                text: appLang.deleteAll,
              ),
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
              proxyDecorator: ProxyDecorator.builder,
              itemBuilder: (BuildContext context, int index) {
                var todo = todos[index];
                List<Item> items = todo.items;
                int itemsDone = items.where((item) => item.done == true).length;
                todo.ratioItemsDone = items.isEmpty ? 0 : itemsDone / items.length;
                return InkWell(
                  key: UniqueKey(),
                  onTap: textFieldAddVisible
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                          setState(() => todoEdit = null);
                          context.go(todoPage, extra: todo);
                        },
                  onLongPress: textFieldAddVisible
                      ? null
                      : () {
                          if (todoSelect == null || todoSelect?.name != todo.name) {
                            resetTextField();
                            setState(() {
                              todoSelect = todo;
                              todoEdit = todo;
                            });
                          } else {
                            resetTextField();
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          todoSelect?.name == todo.name ? AppColor.primary50 : Colors.transparent,
                      border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            children: [
                              Expanded(
                                child: todoRename?.name == todo.name
                                    ? TextField(
                                        autofocus: true,
                                        onChanged: (value) => setState(() => errorDuple = null),
                                        controller: textFieldEditController,
                                        decoration: InputDecoration(
                                          labelText: appLang.newName,
                                          errorText: errorDuple,
                                          suffixIcon: IconButton(
                                            onPressed: textFieldEditController.text.isEmpty
                                                ? null
                                                : () {
                                                    if (todos.any((todo) =>
                                                        todo.name ==
                                                        textFieldEditController.text)) {
                                                      setState(() => errorDuple = appLang.repeTask);
                                                    } else {
                                                      renameTodo(context, todo,
                                                          textFieldEditController.text);
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
                              ),
                              if (todo.priority) ...[
                                const Icon(Icons.star, color: Colors.amber),
                              ],
                              if (todoEdit?.name == todo.name) ...[
                                IconButton(
                                  onPressed: () => resetTextField(),
                                  padding: const EdgeInsets.all(0),
                                  icon: const Icon(Icons.expand_less),
                                ),
                              ],
                              if (!filterPriority &&
                                  !textFieldAddVisible &&
                                  filterTag == null &&
                                  todoSelect == null) ...[
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.unfold_more),
                                )
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                          child: Row(
                            children: [
                              iconStatus(todo),
                              const SizedBox(width: 4),
                              if (items.isNotEmpty) ...[
                                Text('$itemsDone/${items.length}'),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: LinearProgressIndicator(value: itemsDone / items.length),
                                  ),
                                ),
                                Text(todo.displayRatioPercentage()),
                              ] else ...[
                                Text(appLang.emptyTask)
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InputChip(
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                avatar: Icon(Icons.label, color: todo.tag.color),
                                label: Text(appLang.tag(todo.tag.name)),
                                labelPadding: const EdgeInsets.only(right: 0, left: 4),
                              ),
                              if (todo.date != null)
                                InputChip(
                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                  avatar: const Icon(Icons.today),
                                  //label: Text(DateFormat.yMd().format(todo.date!)),
                                  //label: Text(DateFormat('dd/MM/yy').format(todo.date!)),
                                  label: Text(appLang.onDate(todo.date!)),
                                  labelPadding: const EdgeInsets.only(right: 0, left: 4),
                                ),
                            ],
                          ),
                        ),
                        if (todoEdit?.name == todo.name) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              elevation: 2.0,
                              shadowColor: Colors.grey,
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    MaterialButton(
                                      onPressed: () => context
                                          .read<TodoProvider>()
                                          .updatePrirority(todo, !todo.priority),
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(
                                        Icons.star,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                        setState(
                                            () => todoRename = todoRename == null ? todo : null);
                                        textFieldEditController.clear();
                                        setState(() => errorDuple = null);
                                      },
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(
                                        Icons.edit,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () {},
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: PopupMenuButton<Tag>(
                                        child: const Icon(
                                          Icons.label_outline,
                                          color: AppColor.primaryColor,
                                        ),
                                        //onCanceled: () => resetTextField(),
                                        onSelected: (Tag tag) {
                                          context.read<TodoProvider>().updateTag(todo, tag);
                                          //resetTextField();
                                        },
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
                                                        color: AppColor
                                                            .tagColors[Tag.values.indexOf(tag)],
                                                      ),
                                                      Text(appLang.tag(tag.name))
                                                    ]),
                                                  ))
                                              .toList();
                                        },
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () async {
                                        await selectDate(context, todo);
                                        //resetTextField();
                                      },
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(
                                        Icons.today,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () async {
                                        resetTextField();
                                        BannerConfirmDelete(context: context, todo: todo)
                                            .showBanner();
                                        setState(() => todoSelect = todo);
                                      },
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(
                                        Icons.delete,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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

  Icon iconStatus(Todo todo) {
    if (todo.items.isEmpty) return const Icon(Icons.hide_source);
    //if (todo.ratioItemsDone == 0) return const Icon(Icons.hide_source);
    if (todo.ratioItemsDone == 1) return const Icon(Icons.task_alt);
    return const Icon(Icons.rule);
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
    resetTextField();
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

  exportTarea(BuildContext context, Todo todo) async {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    String? directory = await FilePicker.platform.getDirectoryPath();
    bool storagePermission = await requestStoragePermission();
    if (directory != null && storagePermission) {
      String fileName = todo.name;
      if (fileName.length > 30) {
        fileName = fileName.substring(0, 30);
      }
      File backupFile = File('$directory/$fileName.json');
      try {
        await backupFile.writeAsString(jsonEncode(todo.toJson()));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appLang.exportOk} ${backupFile.path}')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLang.exportError)),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLang.processCancel)),
      );
    }
  }

  importTarea(BuildContext context) async {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    bool storagePermission = await requestStoragePermission();
    if (result != null && storagePermission) {
      File file = File(result.files.single.path.toString());
      if (!mounted) return;
      List<Todo> todos = context.read<TodoProvider>().todos;
      try {
        Map<String, dynamic> map = jsonDecode(await file.readAsString());
        Todo todo = Todo.fromJson(map);
        if (todos.any((to) => to.name == todo.name)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appLang.importRepe)),
          );
        } else {
          if (!mounted) return;
          context.read<TodoProvider>().add(todo);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appLang.importOk)),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLang.importError)),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLang.processCancel)),
      );
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permissionStatus = await Permission.storage.status;
      if (permissionStatus.isGranted) return true;
      permissionStatus = await Permission.storage.request();
      return permissionStatus.isGranted ? true : false;
    }
    return true;
  }
}

class BannerConfirmDelete {
  final BuildContext context;
  final Todo? todo;
  const BannerConfirmDelete({required this.context, this.todo});

  showBanner() {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    String content = todo != null ? appLang.deleteTask(todo!.name) : appLang.deleteAllTasks;
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
