
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'alarm_helper.dart';
import 'models/alarm_info.dart';
import 'models/theme_data.dart';


class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  late String _alarmTimeString;
  bool _isRepeatSelected = false;
  final AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding:const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;
                  return ListView(
                    children: snapshot.data!.map<Widget>((alarm) {
                      var alarmTime = DateFormat('hh:mm aa').format(alarm.alarmDateTime!);
                      var gradientColor = GradientTemplate.gradientTemplate[alarm.gradientColorIndex!].colors;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColor,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColor.last.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset:const Offset(4, 4),
                            ),
                          ],
                          borderRadius:const BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.label,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      alarm.title!,
                                      style:const TextStyle(color: Colors.white, fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                                Switch(
                                  onChanged: (bool value) {},
                                  value: true,
                                  activeColor: Colors.white,
                                ),
                              ],
                            ),
                            const Text(
                              'Mon-Fri',
                              style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  alarmTime,
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'avenir', fontSize: 24, fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                    icon:const Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.id);

                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).followedBy([
                      if (_currentAlarms!.length < 5)
                        DottedBorder(
                          strokeWidth: 2,
                          color:const Color(0xFFEAECFF),
                          borderType: BorderType.RRect,
                          radius:const Radius.circular(24),
                          dashPattern:const [5, 4],
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:const BorderRadius.all(Radius.circular(24)),
                            ),
                            child: MaterialButton(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              onPressed: () {
                                _alarmTimeString = DateFormat('HH:mm').format(DateTime.now());
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape:const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  var selectedTime = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                  );
                                                  if (selectedTime != null) {
                                                    final now = DateTime.now();
                                                    var selectedDateTime = DateTime(
                                                        now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                                                    _alarmTime = selectedDateTime;
                                                    setModalState(() {
                                                      _alarmTimeString = DateFormat('HH:mm').format(selectedDateTime);
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmTimeString,
                                                  style:const TextStyle(fontSize: 32),
                                                ),
                                              ),
                                              ListTile(
                                                title:const Text(
                                                    'Repeat',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir',
                                                    fontSize: 24,
                                                  ),
                                                ),
                                                trailing: Switch(
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      _isRepeatSelected = value;
                                                    });
                                                  },
                                                  value: _isRepeatSelected,
                                                ),
                                              ),
                                              const ListTile(
                                                title:Text(
                                                    'Title',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir',
                                                    fontSize: 24,
                                                  ),
                                                ),
                                                trailing: Icon(Icons.arrow_forward_ios),
                                              ),
                                              FloatingActionButton.extended(
                                                onPressed: () {
                                                  onSaveAlarm(_isRepeatSelected);
                                                },
                                                icon: const Icon(Icons.alarm),
                                                label: const Text('Save'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                // scheduleAlarm();
                              },
                              child: Column(
                                children: const <Widget>[
                                  Icon(
                                    Icons.add_alarm,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Alarm',
                                    style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(
                            child: Text(
                              'Only 5 alarms allowed!',
                              style: TextStyle(color: Colors.white),
                            )),
                    ]).toList(),
                  );
                }
                return const Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  void onSaveAlarm(bool isRepeating) {
    DateTime? scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = _alarmTime;
    } else {
      scheduleAlarmDateTime = _alarmTime!.add(const Duration(days: 1));
    }

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      gradientColorIndex: _currentAlarms!.length,
      title: 'alarm',
    );
    _alarmHelper.insertAlarm(alarmInfo);

    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int? id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }
}


