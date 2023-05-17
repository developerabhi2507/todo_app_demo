import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/add_todo_model.dart';
import '../utils/database_helper.dart';
import '../widgets/video_player_screen.dart';
import 'home_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key, required this.todo});
  final Todo todo;

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  DatabaseHelper? _databaseHelper;
  TextEditingController? _textEditingController;
  final _formKey = GlobalKey<FormState>();
  final _audioRecorder = FlutterSoundRecorder();
  final _audioPlayer = FlutterSoundPlayer();
  TextEditingController? _locationController;
  final _textController = TextEditingController();
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
    print('geolocation: ${widget.todo.columnGeolocation}');
    _textEditingController =
        TextEditingController(text: widget.todo.columnText);
    _locationController =
        TextEditingController(text: widget.todo.columnGeolocation);
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
      widget.todo.columnAudio = file.path;
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
      widget.todo.columnAudio = result;
    });
  }

  Future<void> _playAudio() async {
    await _audioPlayer.startPlayer(fromURI: widget.todo.columnAudio);
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
      widget.todo.columnVideo = file.path;
    });
  }

  void _playVideo() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          VideoPlayerScreen(videoPath: widget.todo.columnVideo!),
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
      widget.todo.columnImage = file.path;
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
      widget.todo.columnPdf = file.path;
    });
  }

  void _openPDF() async {
    await OpenFile.open(widget.todo.columnPdf!);
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
      widget.todo.columnDoc = file.path;
    });
  }

  void _openDoc() async {
    await OpenFile.open(widget.todo.columnDoc!);
  }

  Future<void> _getCurrentLocation() async {
    await Permission.locationWhenInUse.request();
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationController!.text =
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
          widget.todo.columnTime = DateTime(
            picked.month,
            picked.day,
            picked.hour,
            time.minute,
          ).toString();
        });
      }
    }
  }

  Future<void> _updateForm() async {
    if (_formKey.currentState!.validate()) {
      print('location: ${_locationController!.text}');
      _formKey.currentState!.save();
      final todo = Todo(
        columnText: _textController.text,
        columnAudio: _audioPath,
        columnVideo: _videoPath,
        columnImage: _imagePath,
        columnPdf: _pdfPath,
        columnDoc: _docPath,
        columnGeolocation: _locationController!.text,
        columnTime: _dateTime.toString(),
      );
      await DatabaseHelper.instance.update(todo);
      // await FirebaseFirestore.instance.collection('todos').add(todo.toMap());
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
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
                  controller: _textEditingController,
                  onChanged: (value) {
                    widget.todo.columnText = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Text',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Text is required';
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
                      child: widget.todo.columnAudio != null
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
                      child: widget.todo.columnVideo != null
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
                      child: InteractiveViewer(
                        clipBehavior: Clip.none,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            child: widget.todo.columnImage != null
                                ? Image.file(File(widget.todo.columnImage!))
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
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
                      child: widget.todo.columnPdf != null
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
                      child: widget.todo.columnDoc != null
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
                      child: widget.todo.columnTime != null
                          ? Text(widget.todo.columnTime.toString())
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _updateForm();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
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

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Todo Detail'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 20.0),
//             Text('Text:'),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: _textEditingController,
//                 onChanged: (value) {
//                   widget.todo.columnText = value;
//                 },
//               ),
//             ),
//             SizedBox(height: 20.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.music_note),
//                     label: const Text('Select'),
//                     onPressed: _selectAudio,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: Icon(
//                         _audioRecorder.isRecording ? Icons.stop : Icons.mic),
//                     label: const Text('Record'),
//                     onPressed: () async {
//                       if (_audioRecorder.isRecording) {
//                         await _stopRecording();
//                       } else {
//                         await _recordAudio();
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: widget.todo.columnAudio != null
//                       ? TextButton.icon(
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Play'),
//                           onPressed: _playAudio,
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('Video'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.video_library),
//                     label: const Text('Select'),
//                     onPressed: _selectVideo,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: widget.todo.columnVideo != null
//                       ? TextButton.icon(
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Play'),
//                           onPressed: _playVideo,
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('Image'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.image),
//                     label: const Text('Select'),
//                     onPressed: _selectImage,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: InteractiveViewer(
//                     clipBehavior: Clip.none,
//                     child: AspectRatio(
//                       aspectRatio: 1,
//                       child: ClipRRect(
//                         child: widget.todo.columnImage != null
//                             ? Image.file(File(widget.todo.columnImage!))
//                             : const SizedBox.shrink(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('PDF'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.picture_as_pdf),
//                     label: const Text('Select'),
//                     onPressed: _selectPDF,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: widget.todo.columnPdf != null
//                       ? TextButton.icon(
//                           icon: const Icon(Icons.open_in_new),
//                           label: const Text('Open'),
//                           onPressed: _openPDF,
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('Doc'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.description),
//                     label: const Text('Select'),
//                     onPressed: _selectDoc,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: widget.todo.columnDoc != null
//                       ? TextButton.icon(
//                           icon: const Icon(Icons.open_in_new),
//                           label: const Text('Open'),
//                           onPressed: _openDoc,
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('Geolocation'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.location_on),
//                     label: const Text('Get Current Location'),
//                     onPressed: _getCurrentLocation,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _locationController,
//                     decoration: const InputDecoration(
//                       labelText: 'Manual Location',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             const Text('Time'),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.access_time),
//                     label: const Text('Select'),
//                     onPressed: _selectDateTime,
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: widget.todo.columnTime != null
//                       ? Text(widget.todo.columnTime.toString())
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               child: const Text('Add'),
//               onPressed: () {
//                 _updateForm();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => HomeScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class ZoomImageView extends StatelessWidget {
// //   final Image imageUrl;

// //   ZoomImageView({required this.imageUrl});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Zoom Image View'),
// //       ),
// //       body: Center(
// //         child: PhotoView(
// //           imageProvider: AssetImage(imageUrl.toString()),
// //           enableRotation: true,
// //         ),
// //       ),
// //     );
// //   }
// // }
        