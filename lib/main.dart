import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MedicineReminderApp());
}

class MedicineReminderApp extends StatefulWidget {
  @override
  _MedicineReminderAppState createState() => _MedicineReminderAppState();
}

class _MedicineReminderAppState extends State<MedicineReminderApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.yellow[100],
      ),
      debugShowCheckedModeBanner: false,
      home: MedicineHomePage(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
      routes: {
        '/history': (context) => HistoryLogPage(),
      },
    );
  }
}

class MedicineHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MedicineHomePage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _MedicineHomePageState createState() => _MedicineHomePageState();
}

class _MedicineHomePageState extends State<MedicineHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  int intakeTimes = 1;
  List<TimeOfDay> intakeTimesList = [TimeOfDay.now()];
  String selectedType = 'Pills';
  String selectedShape = 'pill.png';
  List<bool> selectedDays = List.generate(7, (index) => false);
  List<Map<String, dynamic>> medicines = [];
  List<Map<String, dynamic>> historyLog = [];

  final List<String> types = ['Pills', 'Pump', 'Dose', 'Liquid', 'Injection', 'Other'];
  final List<String> shapes = ['pill.png', 'pill_rounded.png', 'syringe.png', 'ointment.png', 'inhaler.png', 'drug.png'];

  final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> fullWeekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  final List<String> healthFacts = [
    'Drinking water can improve your mood and energy levels.',
    'Exercising regularly can improve mental health.',
    'Eating fruits and vegetables can reduce the risk of chronic diseases.',
    'Getting enough sleep can improve brain function and memory.',
    'Walking for 30 minutes every day can reduce the risk of heart disease.',
    'Laughter can boost your immune system and reduce stress.',
    'Being outdoors in nature can improve your mood and mental health.',
    'Regular physical activity can increase your lifespan.',
    'A healthy diet can improve your skin health.',
    'Meditation and mindfulness can reduce anxiety and stress.',
  ];

  String getRandomHealthFact() {
    final random = Random();
    return healthFacts[random.nextInt(healthFacts.length)];
  }

  Future<void> pickTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: intakeTimesList[index],
    );
    if (picked != null) {
      setState(() {
        intakeTimesList[index] = picked;
        adjustIntakeTimes(index);
      });
    }
  }

  void adjustIntakeTimes(int index) {
    if (index == 0) return;

    for (int i = index; i < intakeTimes; i++) {
      TimeOfDay prevTime = intakeTimesList[i - 1];
      int newHour = (prevTime.hour + 3) % 24;
      int newMinute = prevTime.minute;

      intakeTimesList[i] = TimeOfDay(hour: newHour, minute: newMinute);
    }
  }

  void addMedicine() {
    if (nameController.text.isNotEmpty && doseController.text.isNotEmpty) {
      setState(() {
        medicines.add({
          'name': nameController.text,
          'dose': doseController.text,
          'type': selectedType,
          'shape': selectedShape,
          'times': List.from(intakeTimesList),
          'days': List.generate(7, (index) => selectedDays[index] ? weekDays[index] : '')
              .where((day) => day.isNotEmpty)
              .toList(),
        });
      });
      nameController.clear();
      doseController.clear();
      selectedDays = List.generate(7, (index) => false);
    }
  }

  String getFullDaysString(List<String> days) {
    List<String> fullDays = days.map((day) {
      int index = weekDays.indexOf(day);
      return fullWeekDays[index];
    }).toList();

    return fullDays.join(', ');
  }

  bool isFormExpanded = true;

  void showMedicineDetailsDialog(BuildContext context, Map<String, dynamic> medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(medicine['name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dosage: ${medicine['dose']}g'),
              Text('Type: ${medicine['type']}'),
              Text('Shape: ${medicine['shape']}'),
              Text('Times per day: ${medicine['times'].map((time) => time.format(context)).join(", ")}'),
              Text('Days: ${getFullDaysString(medicine['days'])}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                showTakeMedicineDialog(context, medicine);
              },
              child: Text('Check'),
            ),
          ],
        );
      },
    );
  }

  void showTakeMedicineDialog(BuildContext context, Map<String, dynamic> medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Have you taken the medicine?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  medicines.remove(medicine);
                  historyLog.add(medicine);
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Medicine Reminder', style: TextStyle(color: Colors.brown)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.brown),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.history, color: Colors.brown),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/history',
                arguments: historyLog,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  isFormExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.yellow[800],
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    isFormExpanded = !isFormExpanded;
                  });
                },
              ),
              if (isFormExpanded) ...[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: doseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Dosage (grams)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedType,
                  items: types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Medicine Type'),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: shapes.map((shape) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedShape = shape),
                      child: Image.asset(
                        'assets/images/$shape',
                        width: 40,
                        color: selectedShape == shape ? Colors.yellow[700] : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Times per day:', style: TextStyle(fontSize: 16)),
                    DropdownButton<int>(
                      value: intakeTimes,
                      items: List.generate(5, (index) => index + 1)
                          .map((value) => DropdownMenuItem(value: value, child: Text(value.toString()))).toList(),
                      onChanged: (value) => setState(() {
                        intakeTimes = value!;
                        intakeTimesList = List.generate(intakeTimes, (index) => TimeOfDay.now());
                      }),
                    ),
                  ],
                ),
                Column(
                  children: List.generate(
                    intakeTimes,
                        (index) {
                      String suffix = '';
                      if (index == 0) {
                        suffix = 'st';
                      } else if (index == 1) {
                        suffix = 'nd';
                      } else if (index == 2) {
                        suffix = 'rd';
                      } else {
                        suffix = 'th';
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${index + 1}$suffix Take: ${intakeTimesList[index].format(context)}'),
                          IconButton(
                            icon: Icon(Icons.access_time, color: Colors.yellow[800]),
                            onPressed: () => pickTime(context, index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDays[index] = !selectedDays[index];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedDays[index] ? Colors.yellow[800] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.brown),
                        ),
                        child: Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDays[index] ? Colors.white : Colors.brown,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  ),
                  child: Text('Add Medicine', style: TextStyle(fontSize: 16, color: Colors.brown)),
                ),
                SizedBox(height: 20),
              ],
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      leading: Image.asset('assets/images/${medicine['shape']}', width: 40, color: CupertinoColors.systemYellow),
                      title: Text(
                        medicine['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${medicine['dose']} ${medicine['type']} on ${getFullDaysString(medicine['days'])}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.check, color: Colors.yellow),
                        onPressed: () => showMedicineDetailsDialog(context, medicine),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String randomFact = getRandomHealthFact();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Health Fact'),
                content: Text(randomFact),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.yellow,
        child: Icon(Icons.healing, color: Colors.brown),
      ),
    );
  }
}

class HistoryLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> historyLog =
        ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text('History Log'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: historyLog.isEmpty
            ? Center(child: Text('No medicines taken yet.'))
            : ListView.builder(
                itemCount: historyLog.length,
                itemBuilder: (context, index) {
                  final medicine = historyLog[index];
                  return ListTile(
                    title: Text(medicine['name']),
                    subtitle: Text('${medicine['dose']} - ${medicine['type']}'),
                  );
                },
              ),
      ),
    );
  }
}
