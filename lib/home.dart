import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late VideoPlayerController _controller;
  final TextEditingController _text = TextEditingController();
  String videoURL =
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
  late Timer timer;

  void onSubmit(String text, Function setState) {
    videoURL = text == ""
        ? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        : text;
    initController(setState);
  }

  void initController(setState) {
    _controller = VideoPlayerController.network(videoURL)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                "Failed to load video",
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black),
        );
      });
  }

  @override
  void initState() {
    initController(setState);

    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {});
    });
    super.initState();
  }

  void playPause() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void skip(int seconds) async {
    if (!_controller.value.isInitialized) return;
    _controller.seekTo(Duration(
        milliseconds:
            (await _controller.position)!.inMilliseconds + seconds * 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 400,
            child: TextField(
              onSubmitted: (String text) => onSubmit(text, setState),
              controller: _text,
              decoration: InputDecoration(
                  hintText: "URL",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _text.clear(),
          ),
          IconButton(
              icon: const Icon(Icons.content_paste),
              onPressed: () async {
                ClipboardData? clip =
                    await Clipboard.getData(Clipboard.kTextPlain);
                if (clip != null && clip.text != null) {
                  _text.text = clip.text!;
                }
              }),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => onSubmit(_text.text, setState),
          )
        ],
      ),
      const Padding(padding: EdgeInsets.all(8)),
      if (_controller.value.isInitialized)
        SizedBox(
          width: 500,
          child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller)),
        )
      else
        Container(
          height: 500 / 16 * 9,
          width: 500,
          color: Colors.black,
          child: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      const Padding(padding: EdgeInsets.all(2)),
      Text(
          "${_controller.value.position.toString().split(".")[0]} / ${_controller.value.duration.toString().split(".")[0]}"),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: () => skip(-5), child: const Text("-5s")),
        const Padding(padding: EdgeInsets.all(8)),
        ElevatedButton(
            onPressed: playPause,
            child: Text(_controller.value.isPlaying ? "Pause" : "Play")),
        const Padding(padding: EdgeInsets.all(8)),
        ElevatedButton(
            onPressed: () => skip(5), child: const Text("+5s"))
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            onPressed: () {
              _controller.setPlaybackSpeed(
                  max(0, _controller.value.playbackSpeed - 0.25));
            },
            child: const Text("-0.5")),
        const Padding(padding: EdgeInsets.all(8)),
        ElevatedButton(
            onPressed: () => _controller.setPlaybackSpeed(1),
            child:
                Text("Speed: " + _controller.value.playbackSpeed.toString())),
        const Padding(padding: EdgeInsets.all(8)),
        ElevatedButton(
            onPressed: () {
              _controller
                  .setPlaybackSpeed(_controller.value.playbackSpeed + 0.25);
            },
            child: const Text("+0.5"))
      ]),
      ElevatedButton(
          onPressed: () => saveFrame(context), child: const Text("Save Frame"))
    ]));
  }

  void saveFrame(BuildContext context) async {
    _controller.pause();
    String? filename;
    try {
      filename = await VideoThumbnail.thumbnailFile(
          video: videoURL,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 0,
          maxWidth: 0,
          quality: 100,
          timeMs: (await _controller.position)!.inMilliseconds);
    } catch (e) {
      filename = null;
    }
    if (filename == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Failed to save thumbnail",
          style: TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
      ));
      return;
    }
    print(filename);
    OpenFile.open(filename);
  }
}
