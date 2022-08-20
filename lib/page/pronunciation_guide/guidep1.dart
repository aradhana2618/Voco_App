//page(4(a));
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:loginuicolors/page/home.dart';
import 'package:loginuicolors/page/pronunciation_guide/guidep2.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class PronucitionGuide extends StatefulWidget {
  PronucitionGuide({required this.quotesList, required this.pageNo});
  final List<String> quotesList;
  int pageNo;
  @override
  _Demo2WidgetState createState() => _Demo2WidgetState();
}

class _Demo2WidgetState extends State<PronucitionGuide> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final recorder = FlutterSoundRecorder();

  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Amplitude? _amplitude;

  @override
  void initState() {
    _isRecording = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final Directory appDocDirectory = await getApplicationDocumentsDirectory();
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          path: '${appDocDirectory.path}/recording.mp3',
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100,
        );

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String> _stopRecording() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    return path!;
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
        key: scaffoldKey,
        // backgroundColor: Color(0xFFF1F8F4),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0), // here the desired height
            child: AppBar(
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      //push and remove untill home page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  );
                },
              ),
              title: Text(
                "   VoCo",
                style: GoogleFonts.lora(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.arrow_circle_right), onPressed: () => {}),
              ],
            )),
        body: SafeArea(
            child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: mediaQuery.size.width * 1,
                  height: mediaQuery.size.height * 0.04,
                ),
                Container(
                  width: mediaQuery.size.width * 1,
                  height: mediaQuery.size.height * 0.04,
                  color: Color.fromARGB(255, 249, 217, 217),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: mediaQuery.size.width * 0.8,
                            height: mediaQuery.size.height * 0.03,
                            child: Text(
                              "  Pronunciation Guide",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: mediaQuery.size.height * 0.02,
                              ),
                            )),
                      ],
                    ),
                  ]),
                ),
                SizedBox(
                  height: mediaQuery.size.height * 0.02,
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/vocogft.gif'),
                        fit: BoxFit.cover),
                  ),
                  height: mediaQuery.size.height * 0.39,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: mediaQuery.size.width * 0.4,
                          height: mediaQuery.size.height * 0.35,
                        ),
                        Container(
                          width: mediaQuery.size.width * 0.5,
                          height: mediaQuery.size.height * 0.32,
                          color: Color.fromARGB(255, 249, 217, 217),
                          child: Text(
                            widget.quotesList[widget.pageNo],
                            style: GoogleFonts.lora(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: mediaQuery.size.height * 0.02,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                SizedBox(
                  height: mediaQuery.size.height * 0.02,
                ),
                Container(
                    width: mediaQuery.size.width * 1,
                    height: mediaQuery.size.height * 0.3,
                    color: Color.fromARGB(255, 249, 217, 217),
                    child: SizedBox(
                      child: Container(
                          width: mediaQuery.size.width * 0.48,
                          height: mediaQuery.size.height * 0.39,
                          child: SizedBox(
                              child: GestureDetector(
                            onLongPressDown: (details) async {
                              print('Recording started');
                              // start recording the audio
                              _startRecording();
                              debugPrint("Recording Started");
                            },
                            onLongPressUp: () async {
                              print('Recording stopped');
                              setState(() {
                                _isRecording = false;
                              });
                              // stop recording the audio
                              String recordPath = await _stopRecording();
                              debugPrint(
                                  "Recording Stopped file saved at: ${recordPath}");
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new pronunciation2(
                                    pageNo: widget.pageNo,
                                    quotesList: widget.quotesList,
                                    recordingPath: recordPath,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: _isRecording ? Colors.red : Colors.white,
                              size: 60.0,
                            ),
                          ))),
                    )),
              ]),
        )));
  }
}