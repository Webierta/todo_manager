import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'item.dart';
import 'tag.dart';
import 'todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  refreshTodosBox() {
    _todos = Hive.box<Todo>('todos').values.toList();
    notifyListeners();
  }

  add(Todo todo) {
    Hive.box<Todo>('todos').add(todo);
    _todos.add(todo);
    refreshTodosBox();
    notifyListeners();
  }

  remove(Todo todo) {
    var todosBox = Hive.box<Todo>('todos');
    //int index = todosBox.values.toList().indexOf(todo);
    //todosBox.deleteAt(index);
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) todosBox.delete(key);
    });
    _todos.remove(todo);
    refreshTodosBox();
    notifyListeners();
  }

  removeAll() {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) => todosBox.delete(key));
    _todos.clear();
    refreshTodosBox();
    notifyListeners();
  }

  updatePrirority(Todo todo, bool priority) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.priority = priority;
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  updateTag(Todo todo, Tag tag) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.tag = tag;
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  rename(Todo todo, String newName) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.name = newName;
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  sortOnReorder(List<Todo> todos) {
    var todosBox = Hive.box<Todo>('todos');
    var keys = todosBox.toMap().keys.toList();
    try {
      for (var i = 0; i < keys.length; i++) {
        todosBox.put(keys[i], todos[i]);
      }
    } catch (e) {
      log(e.toString());
    }
    refreshTodosBox();
    notifyListeners();
  }

  sortAZ() {
    var todosBox = Hive.box<Todo>('todos');
    _todos.sort((a, b) => a.name.compareTo(b.name));
    try {
      /* int i = 0;
      todosBox.toMap().keys.forEach((key) {
        todosBox.put(key, _todos[i]);
        i++;
      }); */
      var keys = todosBox.toMap().keys.toList();
      for (var i = 0; i < keys.length; i++) {
        todosBox.put(keys[i], _todos[i]);
      }
    } catch (e) {
      log(e.toString());
    }
    refreshTodosBox();
    notifyListeners();
  }

  sortDone() {
    var todosBox = Hive.box<Todo>('todos');
    for (var todo in _todos) {
      int itemsDone = todo.items.where((item) => item.done == true).length;
      todo.ratioItemsDone = todo.items.isEmpty ? 0 : todo.items.length / itemsDone;
    }
    _todos.sort(((a, b) => b.ratioItemsDone.compareTo(a.ratioItemsDone)));
    /* int i = 0;
    todosBox.toMap().keys.forEach((key) {
      todosBox.put(key, _todos[i]);
      i++;
    }); */
    try {
      var keys = todosBox.toMap().keys.toList();
      for (var i = 0; i < keys.length; i++) {
        todosBox.put(keys[i], _todos[i]);
      }
    } catch (e) {
      log(e.toString());
    }
    refreshTodosBox();
    notifyListeners();
  }

  addItem(Todo todo, Item item) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.items.add(item);
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  removeItem(Todo todo, Item item) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.items.remove(item);
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  /* removeItemsTodo(Todo todo) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todo.items = [];
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  } */

  toggleItem(Todo todo, Item item) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        Item itemToggle = todo.items.firstWhere((it) => it.name == item.name);
        itemToggle.done = !itemToggle.done;
        //int indexItem = todo.items.indexWhere((it) => it.name == item.name);
        //todo.items[indexItem].done = !todo.items[indexItem].done;
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  checkAll(Todo todo, bool done) {
    var todosBox = Hive.box<Todo>('todos');
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        for (var item in todo.items) {
          item.done = done;
        }
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }

  sortItems(Todo todo) {
    var todosBox = Hive.box<Todo>('todos');
    todo.items.sort((a, b) => a.done.toString().compareTo(b.done.toString()));
    todosBox.toMap().forEach((key, value) {
      if (value.name == todo.name) {
        todosBox.put(key, todo);
      }
    });
    refreshTodosBox();
    notifyListeners();
  }
}
