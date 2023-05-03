import 'package:flutter/material.dart';
import 'package:project1/screens/setReminderPage.dart';

import '../helper/databaseHelper.dart';
import '../models/ReminderModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Reminder>> _reminders;

  @override
  void initState() {
    super.initState();

    _reminders = ReminderDatabaseHelper.instance.getAllReminders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SetReminder(),
                              ));
                        },
                        child: Text("Set reminder"))),
                FutureBuilder<List<Reminder>>(
                  future: _reminders,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final reminder = snapshot.data![index];
                          return ListTile(
                            title: Text(reminder.title),
                            subtitle: Text(
                                'Location: ${reminder.location.latitude}, ${reminder.location.longitude}\n'
                                'Radius: ${reminder.radius}\n'
                                'Start Time: ${reminder.startTime}\n'
                                'End Time: ${reminder.endTime}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                ReminderDatabaseHelper.instance
                                    .delete(reminder.id);
                                setState(() {
                                  _reminders = ReminderDatabaseHelper.instance
                                      .getAllReminders();
                                });
                              },
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
