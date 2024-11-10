import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _taskController = TextEditingController();
  String _selectedPriority = 'Medium';
  String _selectedSortOption = 'Priority';
  String? _filterPriority;
  bool? _filterCompletion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Enter task name'),
                ),
              ),
              DropdownButton<String>(
                value: _selectedPriority,
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: addTask,
                child: Text('Add Task'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Sort by: "),
              DropdownButton<String>(
                value: _selectedSortOption,
                items: ['Priority', 'Due Date', 'Completion Status']
                    .map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (newSortOption) {
                  setState(() {
                    _selectedSortOption = newSortOption!;
                  });
                },
              ),
              Text("Filter by Priority: "),
              DropdownButton<String?>(
                value: _filterPriority,
                hint: Text('All'),
                items: [null, 'High', 'Medium', 'Low'].map((String? value) {
                  return DropdownMenuItem<String?>(
                    value: value,
                    child: Text(value ?? 'All'),
                  );
                }).toList(),
                onChanged: (newFilter) {
                  setState(() {
                    _filterPriority = newFilter;
                  });
                },
              ),
              SwitchListTile(
                title: Text("Completed Only"),
                value: _filterCompletion == true,
                onChanged: (value) {
                  setState(() {
                    _filterCompletion = value ? true : null;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getFilteredTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return ListTile(
                      title: Text(task['name']),
                      subtitle: Text('Priority: ${task['priority']}'),
                      leading: Checkbox(
                        value: task['completed'],
                        onChanged: (value) {
                          toggleCompletion(task.id, value);
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addTask() async {
    if (_taskController.text.isNotEmpty) {
      await _firestore.collection('tasks').add({
        'name': _taskController.text,
        'completed': false,
        'priority': _selectedPriority,
        'dueDate': DateTime.now(),
      });
      _taskController.clear();
    }
  }

  Future<void> toggleCompletion(String taskId, bool? isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'completed': isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Stream<QuerySnapshot> _getFilteredTasks() {
    Query query = _firestore.collection('tasks');

    // Apply priority filter if selected
    if (_filterPriority != null) {
      query = query.where('priority', isEqualTo: _filterPriority);
    }

    // Apply completion filter if selected
    if (_filterCompletion != null) {
      query = query.where('completed', isEqualTo: _filterCompletion);
    }

    // Apply sorting based on selected sort option
    switch (_selectedSortOption) {
      case 'Priority':
        query = query.orderBy('priority', descending: false);
        break;
      case 'Due Date':
        query = query.orderBy('dueDate');
        break;
      case 'Completion Status':
        query = query.orderBy('completed', descending: true);
        break;
    }

    return query.snapshots();
  }
}
