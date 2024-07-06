// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';
import 'services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:another_flushbar/flushbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Task Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<Task> tasks = [];  // Initialize your tasks list as empty
  List<Task> filteredTasks = [];
  @override
  void initState() {
    super.initState();
    fetchTasks();  // Call fetchTasks during initState
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }
  Future<void>  fetchTasks() async {
    try {
      setLoading(true);
      List<Task> fetchedTasks = await ApiService().fetchTasks();  // Assuming ApiService has a method fetchTasks returning Future<List<Task>>
      setState(() {
        tasks = fetchedTasks; 
        applyFilters(); 
      });
    } catch (e) {
      // Handle errors, e.g., show a Snackbar or log to console
        print('Failed to fetch tasks: $e');
    }finally{
      setLoading(false);
    }
  }

  void toggleTaskDone(Task updatedTask) async {
    setLoading(true);
    bool success = await ApiService().markTaskDone(updatedTask.id);
    
    if (success) {
      showToast("Task marked as done", backgroundColor: Colors.green);
      await fetchTasks();
    }else{
      showToast("Failed to mark task as done", backgroundColor: Colors.red);
    }
    setLoading(false);
    
  }

  void deleteTask(String taskId) async {
    setLoading(true);
    bool success = await ApiService().deleteTask(taskId);
    if (success) {
      showToast("Task deleted successfully", backgroundColor: Colors.green);
      
      await fetchTasks();
    }else{
      showToast("Failed to delete task", backgroundColor: Colors.red);
    }
    setLoading(false);
  }

   void applyFilters() {
    List<Task> tempTasks = tasks.where((task) {
      final searchMatch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Done') {
        return searchMatch && task.isDone;
      } else if (_selectedFilter == 'UnDone') {
        return searchMatch && !task.isDone;
      }
      return searchMatch;
    }).toList();

    setState(() {
      filteredTasks = tempTasks;
    });
  }

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      applyFilters();
    });
  }

 void updateFilter(String? filter) {
  if (filter != null) {
    setState(() {
      _selectedFilter = filter;
      applyFilters();
    });
  }
}

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                SizedBox(height: 20),
                buttonPart(context),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: filteredTasks[index],
                        onTaskChanged: toggleTaskDone,
                        onDeleteTask: deleteTask,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          isLoading ? Center(child: CircularProgressIndicator()) : Container() // Display the loading indicator when isLoading is true
        ],
      ),
    );
  }

  Row buttonPart(BuildContext context) {
    return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _showTask(context),
                child: const Text('Add New Task', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF290133),
                  padding: EdgeInsets.all(20) // Use backgroundColor instead of primary
                ),
              ),
              _buildFilterButton(),
            ],
          );
  }

   AppBar _buildAppBar() {
    return AppBar(

      backgroundColor: Color(0xFF290133),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Todo App", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),),
        
      ],)
      );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: updateSearchQuery,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Icon(Icons.search, color: Colors.black),
          border: InputBorder.none,
          hintText: 'Search tasks',
          hintStyle: TextStyle(color: Color(0xFF717171)),
        ),
      ),
    );
  }

Widget _buildFilterButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.filter_list, color: Colors.black),
        SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedFilter,
          onChanged: updateFilter, // Now properly accepts a nullable String
          items: <String>['All', 'Done', 'UnDone'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    ),
  );
}



  void _filterTasks(String choice) {
    // Implementation for filtering tasks based on choice
  }

void _showTask(BuildContext context) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDueDate;
  String? titleError;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Add New Task',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter task title',
                      errorText: titleError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        titleError = null; // Clear error on change
                      });
                    },
                    autofocus: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter task description (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDueDate ?? DateTime.now()),
                        );
                        if (time != null) {
                          setModalState(() {
                            selectedDueDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDueDate != null ? DateFormat('yyyy-MM-dd – kk:mm').format(selectedDueDate!) : 'Select date and time',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // To close the dialog
                        },
                        child: Text('Cancel', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty) {
                            setModalState(() {
                              titleError = 'Title cannot be empty'; // Set error message
                            });
                          } else {
                            Task newTask = Task(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                              dueDate: selectedDueDate,
                              isDone: false,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            _addTask(newTask);
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Add Task', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF290133),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        ),
      );
    },
  );
}

void _addTask(Task task) async {
  setLoading(true);
    bool success = await ApiService().addTask(task);
    if (success) {
      showToast("Task added successfully", backgroundColor: Colors.green);
      await fetchTasks();
    } else {
      showToast("Failed to add task", backgroundColor: Colors.red);
    }
    setLoading(false);
}

void showToast(String message, {Color backgroundColor = Colors.black, Color textColor = Colors.white}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 16.0
  );
}




void updateMainState(Task newTask) {
  setState(() {
    tasks.add(newTask);
  });
}

String formatDueDate(DateTime dueDate) {
  return DateFormat('yyyy-MM-dd – kk:mm').format(dueDate);
}


}
