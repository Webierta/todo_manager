import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/menus.dart' as menu;
import '../models/todo.dart';
import '../models/todo_provider.dart';
import '../router/routes_const.dart';
import '../theme/app_color.dart';
import '../widgets/nothing_bear.dart';
import '../widgets/pop_menu.dart';
import '../widgets/proxy_decorator.dart';

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
  Item? itemSelect;
  Item? itemEdit;
  Item? itemRename;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textFieldAddItemController.dispose();
    textFieldRenameItemController.dispose();
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

  Widget? header(BuildContext context, Todo todo) {
    if (!textFieldAddItemVisible) return null;
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return TextField(
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
                  if (todo.items.any((item) => item.name == textFieldAddItemController.text)) {
                    setState(() => errorDuple = appLang.repeItem);
                  } else {
                    addItem(context, todo, textFieldAddItemController.text);
                  }
                },
          icon: const Icon(Icons.add_circle),
        ),
      ),
    );
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
          Chip(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 0),
            label: Text('$itemsDone/${items.length}'),
          ),
          const SizedBox(width: 4),
          Chip(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 0),
            label: Text(todo.displayRatioPercentage()),
          ),
          PopupMenuButton<menu.MenuItem>(
            onCanceled: () => resetTextFieldAddItem(),
            onSelected: (menu.MenuItem item) {
              resetTextFieldAddItem();
              if (item == menu.MenuItem.checkAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, true));
              } else if (item == menu.MenuItem.uncheckAll) {
                setState(() => context.read<TodoProvider>().checkAll(todo, false));
              } else if (item == menu.MenuItem.sortAZ) {
                setState(() => context.read<TodoProvider>().sortItemsAZ(todo));
              } else if (item == menu.MenuItem.sortPriority) {
                setState(() => context.read<TodoProvider>().sortItemsPriority(todo));
              } else if (item == menu.MenuItem.deleteAll) {
                deleteAll(context, todo);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<menu.MenuItem>>[
              PopMenu.buildItem(context: context, value: menu.MenuItem.sortAZ),
              PopMenu.buildItem(context: context, value: menu.MenuItem.sortPriority),
              const PopupMenuDivider(),
              PopMenu.buildItem(context: context, value: menu.MenuItem.checkAll),
              PopMenu.buildItem(context: context, value: menu.MenuItem.uncheckAll),
              const PopupMenuDivider(),
              PopMenu.buildItem(context: context, value: menu.MenuItem.deleteAll),
            ],
          ),
        ],
      ),
      body: items.isEmpty && !textFieldAddItemVisible
          ? const NothingBear(isPageTask: false)
          : ReorderableListView.builder(
              shrinkWrap: true,
              scrollController: scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              header: header(context, todo),
              buildDefaultDragHandles: false,
              itemCount: todo.items.length,
              onReorder: (oldIndex, newIndex) {
                resetTextFieldAddItem();
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Item itemMove = items.removeAt(oldIndex);
                  items.insert(newIndex, itemMove);
                });
                context.read<TodoProvider>().sortItemsOnReorder(todo);
              },
              proxyDecorator: ProxyDecorator.builder,
              itemBuilder: (context, int index) {
                if (items.isEmpty) return const Text('');
                var item = items[index];
                return InkWell(
                  key: UniqueKey(),
                  onTap: textFieldAddItemVisible ? null : () => toggleItem(context, todo, item),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: itemSelect?.name == item.name
                          ? AppColor.primary50
                          : item.done
                              ? Colors.grey[400] // black12
                              : null,
                      border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
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
                              child: Container(
                                child: itemRename?.name == item.name
                                    ? TextField(
                                        autofocus: true,
                                        onChanged: (value) => setState(() => errorDuple = null),
                                        controller: textFieldRenameItemController,
                                        decoration: InputDecoration(
                                          labelText: appLang.newName,
                                          errorText: errorDuple,
                                          suffixIcon: IconButton(
                                            onPressed: textFieldRenameItemController.text.isEmpty
                                                ? null
                                                : () {
                                                    if (todo.items.any((item) =>
                                                        item.name ==
                                                        textFieldRenameItemController.text)) {
                                                      setState(() => errorDuple = appLang.repeItem);
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
                                          fontSize: 18,
                                          fontStyle: item.done ? FontStyle.italic : null,
                                          color: itemEdit?.name == item.name ? Colors.black : null,
                                          decoration: item.done
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: Colors.red,
                                        ),
                                      ),
                              ),
                            ),
                            IconButton(
                              onPressed: textFieldAddItemVisible
                                  ? null
                                  : () => toggleItem(context, todo, item),
                              icon: Icon(
                                item.done ? Icons.check_box : Icons.check_box_outline_blank,
                                color: itemEdit?.name == item.name ? Colors.black : null,
                              ),
                            ),
                            if (itemEdit?.name == item.name) ...[
                              IconButton(
                                onPressed: () => resetTextFieldAddItem(),
                                icon: const Icon(Icons.expand_less, color: Colors.black),
                              ),
                            ],
                            if (itemEdit?.name != item.name) ...[
                              ReorderableDragStartListener(
                                index: index,
                                enabled: itemEdit == null && !textFieldAddItemVisible,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.unfold_more,
                                    color: itemEdit == null && !textFieldAddItemVisible
                                        ? null
                                        : Colors.grey,
                                  ),
                                ), // unfold_more
                              ),
                            ],
                          ],
                        ),
                        if (itemEdit?.name == item.name) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              elevation: 2.0,
                              color: AppColor.primaryColor,
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
                                      child: const Icon(Icons.priority_high, color: Colors.white),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        setState(
                                            () => itemRename = itemRename == null ? item : null);
                                        textFieldRenameItemController.clear();
                                        setState(() => errorDuple = null);
                                      },
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(Icons.edit, color: Colors.white),
                                    ),
                                    MaterialButton(
                                      onPressed: () => removeItem(context, todo, item),
                                      shape: const CircleBorder(),
                                      minWidth: 0,
                                      padding: const EdgeInsets.all(5),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      child: const Icon(Icons.delete, color: Colors.white),
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
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          resetTextFieldAddItem(visible: !textFieldAddItemVisible);
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          }
        },
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
    setState(() => itemSelect = todo.items.firstWhere((it) => it.name == name));
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
          .whenComplete(() {
        Future.delayed(const Duration(milliseconds: 500), (() {
          setState(() => itemSelect = null);
        }));
      });
    }
  }

  toggleItem(BuildContext context, Todo todo, Item item) async {
    resetTextFieldAddItem();
    setState(() => itemSelect = item);
    context.read<TodoProvider>().toggleItem(todo, item);
    Future.delayed(const Duration(milliseconds: 500), () {
      todo.items.sort((a, b) => a.done.toString().compareTo(b.done.toString()));
      context.read<TodoProvider>().sortItems(todo);
    });
    Future.delayed(const Duration(milliseconds: 1000), (() {
      setState(() => itemSelect = null);
      if (todo.ratioItemsDone == 1) {
        showDialogCompleted(context);
      }
    }));
  }

  showDialogCompleted(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(appLang.taskCompleted),
        contentTextStyle: Theme.of(context)
            .typography
            .white
            .headlineSmall
            ?.copyWith(color: AppColor.primaryColor),
        leading: const Icon(
          Icons.check_circle_outline,
          size: 42,
          color: AppColor.primaryColor,
        ),
        backgroundColor: AppColor.primary50,
        forceActionsBelow: true,
        actions: <Widget>[
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).removeCurrentMaterialBanner(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  setPriorityItem(BuildContext context, Todo todo, Item item) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    context.read<TodoProvider>().setPriorityItem(todo, item);
  }

  removeItem(BuildContext context, Todo todo, Item item) {
    context.read<TodoProvider>().removeItem(todo, item);
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
