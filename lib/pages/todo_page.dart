import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../router/routes_const.dart';
import '../theme/app_color.dart';
import '../widgets/nothing_bear.dart';

enum MenuItem { checkAll, uncheckAll, sortAZ, sortPriority, deleteAll }

class TodoPage extends StatefulWidget {
  final Todo todo;
  const TodoPage({super.key, required this.todo});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController textFieldAddItemController = TextEditingController();
  TextEditingController textFieldRenameItemController = TextEditingController();
  bool textFieldAddItemVisible = false;
  String? errorDuple;
  final keyAnimated = GlobalKey<AnimatedListState>();
  Item? itemSelect;
  Item? itemEdit;
  Item? itemRename;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textFieldAddItemController.dispose();
    textFieldRenameItemController.dispose();
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
      itemEdit = null;
      textFieldRenameItemController.clear();
      itemRename = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    List<Todo> todos = context.watch<TodoProvider>().todos;
    Todo todo = todos.firstWhere((to) => to.name == widget.todo.name);
    List<Item> items = todo.items;
    int itemsDone = items.where((item) => item.done == true).length;
    todo.ratioItemsDone = items.isEmpty ? 0 : itemsDone / items.length;

    /* bool buttonInactive(Item item) {
      if (textFieldAddItemVisible) return true;
      if (itemSelect == null) return false;
      return itemSelect?.name != item.name;
    } */

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            context.go(homePage);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(todo.name),
        actions: [
          InputChip(
            labelPadding: const EdgeInsets.symmetric(horizontal: 0),
            label: Text('$itemsDone/${items.length}'),
          ),
          InputChip(
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              label: Text(todo.displayRatioPercentage())),
          PopupMenuButton<MenuItem>(
            onCanceled: () => resetTextFieldAddItem(),
            onSelected: (MenuItem item) {
              if (item == MenuItem.checkAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, true));
              } else if (item == MenuItem.uncheckAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, false));
              } else if (item == MenuItem.sortAZ) {
                setState(() => context.read<TodoProvider>().sortItemsAZ(todo));
              } else if (item == MenuItem.sortPriority) {
                setState(() => context.read<TodoProvider>().sortItemsPriority(todo));
              } else if (item == MenuItem.deleteAll) {
                deleteAll(context, todo);
              }
              resetTextFieldAddItem();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
              PopupMenuItem<MenuItem>(
                value: MenuItem.sortAZ,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.sort_by_alpha),
                  title: Text(appLang.sortAZ),
                ),
              ),
              PopupMenuItem<MenuItem>(
                value: MenuItem.sortPriority,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.priority_high),
                  title: Text(appLang.sortPriority),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<MenuItem>(
                value: MenuItem.checkAll,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.check_box_outlined),
                  title: Text(appLang.checkAll),
                ),
              ),
              PopupMenuItem<MenuItem>(
                value: MenuItem.uncheckAll,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.check_box_outline_blank),
                  title: Text(appLang.uncheckAll),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<MenuItem>(
                value: MenuItem.deleteAll,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.delete_forever),
                  title: Text(appLang.deleteItems),
                ),
              ),
            ],
          ),
        ],
      ),
      body: items.isEmpty && !textFieldAddItemVisible
          ? const NothingBear(isPageTask: false)
          : Column(
              children: [
                if (textFieldAddItemVisible)
                  TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() => errorDuple = null),
                    controller: textFieldAddItemController,
                    decoration: InputDecoration(
                      labelText: appLang.newItem,
                      errorText: errorDuple,
                      suffixIcon: IconButton(
                        onPressed: textFieldAddItemController.text.isEmpty
                            ? null
                            : () {
                                if (todo.items
                                    .any((item) => item.name == textFieldAddItemController.text)) {
                                  setState(() => errorDuple = appLang.repeItem);
                                } else {
                                  addItem(context, todo, textFieldAddItemController.text);
                                }
                              },
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
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
                        child: InkWell(
                          onTap: textFieldAddItemVisible
                              ? null
                              : () => toggleItem(context, todo, item),
                          onLongPress: textFieldAddItemVisible
                              ? null
                              : () {
                                  if (itemSelect == null || itemSelect?.name != item.name) {
                                    resetTextFieldAddItem();
                                    setState(() {
                                      itemSelect = item;
                                      itemEdit = item;
                                    });
                                  } else {
                                    resetTextFieldAddItem();
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: itemSelect?.name == item.name
                                  ? AppColor.primary50
                                  : item.done
                                      ? Colors.black12
                                      : Colors.transparent,
                              border: const Border(
                                bottom: BorderSide(color: Colors.grey, width: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Visibility(
                                      visible: item.priority,
                                      maintainState: true,
                                      maintainAnimation: true,
                                      maintainSize: true,
                                      child: const Icon(Icons.priority_high, color: Colors.red),
                                    ),
                                    Expanded(
                                      child: itemRename?.name == item.name
                                          ? TextField(
                                              autofocus: true,
                                              onChanged: (value) =>
                                                  setState(() => errorDuple = null),
                                              controller: textFieldRenameItemController,
                                              decoration: InputDecoration(
                                                //isDense: true,
                                                //filled: true,
                                                //fillColor: Colors.teal[50],
                                                labelText: appLang.newName,
                                                errorText: errorDuple,
                                                suffixIcon: IconButton(
                                                  onPressed: textFieldRenameItemController
                                                          .text.isEmpty
                                                      ? null
                                                      : () {
                                                          if (todo.items.any((item) =>
                                                              item.name ==
                                                              textFieldRenameItemController.text)) {
                                                            setState(() =>
                                                                errorDuple = appLang.repeItem);
                                                          } else {
                                                            renameItem(context, todo, item,
                                                                textFieldRenameItemController.text);
                                                          }
                                                        },
                                                  icon: const Icon(Icons.published_with_changes),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              item.name,
                                              style: TextStyle(
                                                  fontStyle: item.done ? FontStyle.italic : null,
                                                  decoration: item.done
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                  decorationColor: Colors.red),
                                            ),
                                    ),
                                    if (itemEdit?.name == item.name) ...[
                                      IconButton(
                                        onPressed: () => resetTextFieldAddItem(),
                                        icon: const Icon(Icons.expand_less),
                                      ),
                                    ],
                                    IconButton(
                                      onPressed: textFieldAddItemVisible
                                          ? null
                                          : () => toggleItem(context, todo, item),
                                      icon: Icon(item.done
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank),
                                    ),
                                  ],
                                ),
                                if (itemEdit?.name == item.name) ...[
                                  Material(
                                    elevation: 2.0,
                                    shadowColor: Colors.grey,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          MaterialButton(
                                            onPressed: () => setPriorityItem(context, todo, item),
                                            shape: const CircleBorder(),
                                            minWidth: 0,
                                            padding: const EdgeInsets.all(5),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            child: const Icon(
                                              Icons.priority_high,
                                              color: AppColor.primaryColor,
                                            ),
                                          ),
                                          MaterialButton(
                                            onPressed: () {
                                              setState(() =>
                                                  itemRename = itemRename == null ? item : null);
                                              textFieldRenameItemController.clear();
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
                                            onPressed: () => removeItem(context, todo, item),
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
                                ],
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
        backgroundColor: textFieldAddItemVisible ? Colors.red : null,
        child: textFieldAddItemVisible ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
    );
  }

  renameItem(BuildContext context, Todo todo, Item item, String name) {
    context.read<TodoProvider>().renameItem(todo, item, name);
    resetTextFieldAddItem();
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
    // crollController.position.maxScrollExtent
    // minScrollExtent // scrollController.initialScrollOffset,
    if (scrollController.hasClients) {
      scrollController
          .animateTo(
            position.toDouble() * 50,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          )
          .whenComplete(() => keyAnimated.currentState?.insertItem(
                indice,
                duration: const Duration(milliseconds: 500),
              ));
    }
    //keyAnimated.currentState?.insertItem(indice, duration: const Duration(milliseconds: 500));
  }

  toggleItem(BuildContext context, Todo todo, Item item) {
    //ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    resetTextFieldAddItem();
    setState(() => itemSelect = item);
    context.read<TodoProvider>().toggleItem(todo, item);
    Future.delayed(const Duration(milliseconds: 500), () {
      todo.items.sort((a, b) => a.done.toString().compareTo(b.done.toString()));
      context.read<TodoProvider>().sortItems(todo);
    });
    Future.delayed(const Duration(milliseconds: 1000), (() => setState(() => itemSelect = null)));
  }

  setPriorityItem(BuildContext context, Todo todo, Item item) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    //setState(() => itemSelect = item);
    context.read<TodoProvider>().setPriorityItem(todo, item);
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
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<TodoProvider>().removeItem(todo, item);
    });
  }

  deleteAll(BuildContext context, Todo todo) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(appLang.deleteAllItems),
        leading: const Icon(Icons.delete_forever),
        actions: <Widget>[
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(appLang.cancel),
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
            child: Text(appLang.confirm),
          ),
        ],
      ),
    );
  }
}
