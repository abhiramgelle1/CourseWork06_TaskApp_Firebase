import 'package:flutter/material.dart';
import 'task.dart'; // Ensure the Task model is correctly defined in a separate file.

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  final TextEditingController _taskNameController = TextEditingController();
  String _selectedPriority = 'Low'; // Default priority

  // Add a task to the list
  void _addTask() {
    final String taskName = _taskNameController.text;
    if (taskName.isNotEmpty) {
      setState(() {
        tasks.add(Task(name: taskName, priority: _selectedPriority));
        _taskNameController.clear();
        _sortTasks(); // Sort tasks every time a new one is added
      });
    }
  }

  // Toggle task completion status
  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  // Remove a task from the list
  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Sort tasks by priority
  void _sortTasks() {
    tasks.sort((Task a, Task b) {
      return _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
    });
  }

  // Helper function to convert priority to numerical value
  int _priorityValue(String priority) {
    switch (priority) {
      case 'High':
        return 1;
      case 'Medium':
        return 2;
      case 'Low':
        return 3;
      default:
        return 3;
    }
  }

  // Function to count completed and incomplete tasks
  Map<String, int> _countTasks() {
    int completed = 0;
    int incomplete = 0;
    for (Task task in tasks) {
      if (task.isCompleted) {
        completed++;
      } else {
        incomplete++;
      }
    }
    return {'completed': completed, 'incomplete': incomplete};
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> taskCount =
        _countTasks(); // Call this here to update each time the state changes
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Enter Task Name',
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    items: ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              onSubmitted: (_) =>
                  _addTask(), // Add task when submitting the form
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Completed: ${taskCount['completed']} Incomplete: ${taskCount['incomplete']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('Priority: ${task.priority}'),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(index);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
