import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:row_collection/row_collection.dart';

import '../models/launch.dart';

/// LAUNCH COUNTDOWN WIDGET
/// Stateful widget used to display a countdown to the next launch.
class LaunchCountdown extends StatefulWidget {
  final Launch launch;

  LaunchCountdown(this.launch);
  State createState() => _LaunchCountdownState();
}

class _LaunchCountdownState extends State<LaunchCountdown>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.launch.launchDate.millisecondsSinceEpoch -
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Countdown(
      animation: StepTween(
        begin: widget.launch.launchDate.millisecondsSinceEpoch,
        end: DateTime.now().millisecondsSinceEpoch,
      ).animate(_controller),
      launchDate: widget.launch.launchDate,
      name: widget.launch.name,
      url: widget.launch.getVideo,
    );
  }
}

class Countdown extends AnimatedWidget {
  final Animation<int> animation;
  final DateTime launchDate;
  final String name, url;

  Countdown({
    Key key,
    this.animation,
    this.launchDate,
    this.name,
    this.url,
  }) : super(key: key, listenable: animation);

  @override
  build(BuildContext context) {
    Duration _launchDateDiff = launchDate.difference(DateTime.now());
    return launchDate.isAfter(DateTime.now())
        ? Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _columnItem(getTimer(_launchDateDiff.inDays), "spacex.home.tab.counter.day", context),
                _columnItem(getTimer(_launchDateDiff.inHours), "spacex.home.tab.counter.hour", context),
                _columnItem(getTimer(_launchDateDiff.inMinutes), "spacex.home.tab.counter.min", context),
                _columnItem(getTimer(_launchDateDiff.inSeconds), "spacex.home.tab.counter.sec", context),
              ],
            ),
          )
        : InkWell(
            onTap: () async => await FlutterWebBrowser.openWebPage(
                  url: url,
                  androidToolbarColor: Theme.of(context).primaryColor,
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.play_arrow, size: 30),
                Separator.smallSpacer(),
                Text(
                  FlutterI18n.translate(
                    context,
                    'spacex.home.tab.live_mission',
                  ).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontFamily: 'RobotoMono'),
                ),
              ],
            ),
          );
  }

  Widget _columnItem (String value, String descriptionValue, BuildContext context){
    return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _countItem(value, Theme.of(context).textTheme.headline),
              _countItem(
                FlutterI18n.translate(
                    context,
                    descriptionValue,
                  )
                , Theme.of(context).textTheme.overline
              )
            ],
          );
  }

  Widget _countItem (String value, TextStyle style){
      return Padding(
        padding: EdgeInsets.only(top: 8, left: 8),
        child: Text(
                value,
                style: style,
              ),
      );
  }

  String getTimer(int time) {

    String _timeString = time.toString();

    if (time > Duration.secondsPerDay) {
     return ((time % 60)~/ 10).toString() + ((time % 60) % 10).toString();
    }
    else if (time > Duration.minutesPerDay){
      return ((time % 60)~/ 10).toString() + ((time % 60) % 10).toString();
    }
    else if (time > Duration.hoursPerDay){
      return ((time % 24) ~/ 10).toString() + ((time % 24) % 10).toString();
    }
    else {
      return _timeString;
    }
  }
}
