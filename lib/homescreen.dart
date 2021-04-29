import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/providers/calendar.dart';
import 'package:flutter_calendar/widgets/rounded_input_field.dart';
import 'package:flutter_calendar/widgets/show_up.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:provider/provider.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(2020, 10, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    DateTime.now(): [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<List<Event>> _selectedEvents;
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  StateSetter _setState;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  final kFirstDay = DateTime.now();
  final kLastDay = DateTime(
      DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
  bool isDateSelected = false;

  final kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll(_kEventSource);

  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  Future<bool> _addEventDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) {
        return ShowUp(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            title: Text(
              'Add Event',
              style: TextStyle(
                  // fontWeight: FontWeight.w700,
                  ),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                _setState = setState;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: RoundedInputField(
                          backgroundColor:
                              Colors.deepOrangeAccent.withAlpha(30),
                          borderColor: Colors.deepOrangeAccent.withAlpha(30),
                          hintText: 'Event Name',
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a name for the event';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {
                              _eventName = value;
                            });

                            Provider.of<CalendarClient>(context, listen: false)
                                .insert(_eventName, startTime, endTime);
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            showPicker(
                              accentColor: Colors.deepOrange,
                              unselectedColor: Colors.deepOrangeAccent[100],
                              borderRadius: 30,
                              context: context,
                              value: _time,
                              onChange: onTimeChanged,
                              minuteInterval: MinuteInterval.ONE,
                              disableHour: false,
                              disableMinute: false,
                              minMinute: 0,
                              maxMinute: 59,
                              // Optional onChange to receive value as DateTime
                              onChangeDateTime: (DateTime dateTime) {
                                _setState(() {
                                  startTime = DateTime(
                                    _selectedDay.year,
                                    _selectedDay.month,
                                    _selectedDay.day,
                                    dateTime.hour,
                                    dateTime.minute,
                                    dateTime.second,
                                    dateTime.millisecond,
                                    dateTime.microsecond,
                                  );
                                });
                                print(startTime);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 10, bottom: 10, left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Start Time'),
                              Text(DateFormat.jm().format(startTime)),
                              Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            showPicker(
                              accentColor: Colors.deepOrange,
                              unselectedColor: Colors.deepOrangeAccent[100],
                              borderRadius: 30,
                              context: context,
                              value: _time,
                              onChange: onTimeChanged,
                              minuteInterval: MinuteInterval.ONE,
                              disableHour: false,
                              disableMinute: false,
                              minMinute: 0,
                              maxMinute: 59,
                              // Optional onChange to receive value as DateTime
                              onChangeDateTime: (DateTime dateTime) {
                                _setState(() {
                                  endTime = DateTime(
                                    _selectedDay.year,
                                    _selectedDay.month,
                                    _selectedDay.day,
                                    dateTime.hour,
                                    dateTime.minute,
                                    dateTime.second,
                                    dateTime.millisecond,
                                    dateTime.microsecond,
                                  );
                                });
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 10, bottom: 10, left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('End Time'),
                              Text(DateFormat.jm().format(endTime)),
                              Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    // fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPrimary: Colors.black,
                  shadowColor: Colors.grey[400],
                  elevation: 5,
                  primary: Colors.grey[100],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    // fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPrimary: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  primary: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0XFF181819),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: size.height * 0.06,
              ),
              ShowUp(
                delay: 400,
                child: Text(
                  'Flutter Calendar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF4111),
                    // color: Colors.white,
                    fontSize: size.height * 0.03,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Dosis',
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              ShowUp(
                delay: 800,
                child: Text(
                  'Select a date to show/add events',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: Color(0xFFFF4111),
                    color: Colors.deepOrangeAccent[100],
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Dosis',
                  ),
                ),
              ),
              ShowUp(
                delay: 1000,
                child: TableCalendar(
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.grey[500],
                      // fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.grey[500],
                      // fontWeight: FontWeight.bold,
                    ),
                    dowTextFormatter: (date, locale) =>
                        DateFormat.E(locale).format(date)[0],
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFFFF4111),
                      shape: BoxShape.circle,
                    ),
                    cellMargin: EdgeInsets.all(4),
                    defaultTextStyle: TextStyle(
                      color: Colors.white,
                      // fontSize: mediaWidth * 0.034,
                    ),
                    todayDecoration: BoxDecoration(
                      // color: const Color(0xFFFF795C),
                      // color: Colors.orange,
                      color: Colors.deepOrangeAccent[100],
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: mediaWidth * 0.034,
                    ),
                    holidayTextStyle: TextStyle(
                      color: Colors.white,
                      // fontSize: mediaWidth * 0.034,
                    ),
                    outsideTextStyle: TextStyle(
                      // fontSize: mediaWidth * 0.034,
                      color: Colors.white,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.white,
                      // fontSize: mediaWidth * 0.034,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.white,
                      // fontSize: mediaWidth * 0.034,
                    ),
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      // color: const Color(0xFFFF4111),
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w400,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      // color: const Color(0xFFFF4111),
                      // color: Colors.orange,
                      size: 35,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      // color: const Color(0xFFFF4111),
                      // color: Colors.orange,
                      size: 35,
                    ),
                    formatButtonVisible: false,
                  ),
                  selectedDayPredicate: (day) {
                    // Use `selectedDayPredicate` to determine which day is currently selected.
                    // If this returns true, then `day` will be marked as selected.

                    // Using `isSameDay` is recommended to disregard
                    // the time-part of compared DateTime objects.
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      // Call `setState()` when updating the selected day
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        isDateSelected = true;
                      });
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      // Call `setState()` when updating calendar format
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    // No need to call `setState()` here
                    _focusedDay = focusedDay;
                  },
                ),
              ),
            ],
          ),
          if (isDateSelected)
            ShowUp(
              child: Container(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.33,
                  minChildSize: 0.3,
                  maxChildSize: 0.85,
                  builder: (BuildContext context, myscrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                              child: Icon(
                            Icons.horizontal_rule_rounded,
                            size: 35,
                          )),
                          Container(
                            padding: EdgeInsets.only(
                              left: 30,
                              right: 30,
                            ),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Events',
                                  style: TextStyle(
                                    fontSize: size.width * 0.05,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // setState(() {
                                    //   isDateSelected = false;
                                    // });
                                    _addEventDialog();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(9),
                                      ),
                                      color: Colors.black,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ValueListenableBuilder<List<Event>>(
                                valueListenable: _selectedEvents,
                                builder: (context, value, _) {
                                  return value.length > 1
                                      ? ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          controller: myscrollController,
                                          itemCount: value.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () =>
                                                  print('${value[index]}'),
                                              title: Text('${value[index]}'),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text('No Event'),
                                        );
                                }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 /*
 ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    controller: myscrollController,
                                    itemCount: 25,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(
                                          'Event $index',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  */