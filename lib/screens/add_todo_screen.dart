import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app_demo/screens/home_screen.dart';

import '../models/add_todo_model.dart';
import '../utils/database_helper.dart';
import '../widgets/video_player_screen.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key, required this.title});
  final String title;

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _audioRecorder = FlutterSoundRecorder();
  final _audioPlayer = FlutterSoundPlayer();
  final _textController = TextEditingController();
  final _locationController = TextEditingController();
  String? _audioPath;
  String? _videoPath;
  String? _imagePath;
  String? _pdfPath;
  String? _docPath;
  Position? _position;
  DateTime? _dateTime;
  LocationPermission? permission;

  @override
  void initState() {
    super.initState();
    _audioRecorder.openRecorder();
    _audioPlayer.openPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  void _selectAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _audioPath = file.path;
    });
  }

  Future<void> _recordAudio() async {
    await Permission.audio.request();
    await Permission.microphone.request();
    await _audioRecorder.openRecorder();
    await _audioRecorder.startRecorder(
        toFile: 'audio.mp4', codec: Codec.defaultCodec);
  }

  Future<void> _stopRecording() async {
    final result = await _audioRecorder.stopRecorder();
    setState(() {
      _audioPath = result;
    });
  }

  Future<void> _playAudio() async {
    await _audioPlayer.startPlayer(fromURI: _audioPath);
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stopPlayer();
  }

  void _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _videoPath = file.path;
    });
  }

  void _playVideo() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VideoPlayerScreen(videoPath: _videoPath!),
    ));
  }

  void _selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _imagePath = file.path;
    });
  }

  void _selectPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _pdfPath = file.path;
    });
  }

  void _openPDF() async {
    await OpenFile.open(_pdfPath!);
  }

  void _selectDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
      allowMultiple: false,
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _docPath = file.path;
    });
  }

  void _openDoc() async {
    await OpenFile.open(_docPath!);
  }

  Future<void> _getCurrentLocation() async {
    await Permission.locationWhenInUse.request();
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationController.text =
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  void _selectDateTime() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print('location: ${_locationController.text}');
      _formKey.currentState!.save();
      final todo = Todo(
        columnText: _textController.text,
        columnAudio: _audioPath,
        columnVideo: _videoPath,
        columnImage: _imagePath,
        columnPdf: _pdfPath,
        columnDoc: _docPath,
        columnGeolocation: _locationController.text,
        columnTime: _dateTime.toString(),
      );
      await DatabaseHelper.instance.insert(todo);
      // await FirebaseFirestore.instance.collection('todos').add(todo.toMap());
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text('Audio'),
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.music_note),
                        label: const Text('Select'),
                        onPressed: _selectAudio,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    SizedBox(
                      width: 110,
                      child: ElevatedButton.icon(
                        icon: Icon(_audioRecorder.isRecording
                            ? Icons.stop
                            : Icons.mic),
                        label: const Text('Record'),
                        onPressed: () async {
                          if (_audioRecorder.isRecording) {
                            await _stopRecording();
                          } else {
                            await _recordAudio();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _audioPath != null
                          ? TextButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              onPressed: _playAudio,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Video'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text('Select'),
                        onPressed: _selectVideo,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _videoPath != null
                          ? TextButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              onPressed: _playVideo,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Image'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Select'),
                        onPressed: _selectImage,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _imagePath != null
                          ? Image.file(File(_imagePath!))
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('PDF'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Select'),
                        onPressed: _selectPDF,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _pdfPath != null
                          ? TextButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open'),
                              onPressed: _openPDF,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Doc'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.description),
                        label: const Text('Select'),
                        onPressed: _selectDoc,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _docPath != null
                          ? TextButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open'),
                              onPressed: _openDoc,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Geolocation'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.location_on),
                        label: const Text('Get Current Location'),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Manual Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Time'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: const Text('Select'),
                        onPressed: _selectDateTime,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _dateTime != null
                          ? Text(_dateTime.toString())
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _submitForm();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
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
