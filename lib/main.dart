import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/audio.dart';

//import package files

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAudioList(),
    );
  }
}

//apply this class on home: attribute at MaterialApp()
class MyAudioList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAudioList(); //create state
  }
}

class _MyAudioList extends State<MyAudioList> {
  var files;
  IconData playicon = Icons.play_arrow;
  late AudioPlayer _player;
  late AudioCache cache;
  bool isPlay = false;
  var playindex;

  void getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0]
        .rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["mp3"] //optional, to filter files, list only mp3 files
        );
    setState(() {}); //update the UI
  }

  void permissionStorage() async {
    await Permission.storage.request();
    if (await Permission.storage.request().isGranted) {
      print("Granted");
    }
  }

  @override
  void initState() {
    _player = AudioPlayer();
    cache = AudioCache(fixedPlayer: _player);
    permissionStorage();
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                },
              )
            ],
            title: Text("Your Song"),
            backgroundColor: Colors.redAccent),
        body: files == null
            ? Text("Searching File")
            : ListView.builder(
                //if file/folder list is grabbed, then show here
                itemCount: files?.length ?? 0,
                itemBuilder: (context, index) {
                  if (playindex == index) {
                    isPlay
                        ? playicon = Icons.pause
                        : playicon = Icons.play_arrow;
                  } else {
                    playicon = Icons.play_arrow;
                  }

                  return Card(
                      child: ListTile(
                    title: Text(files[index].path.split('/').last),
                    leading: Icon(Icons.audiotrack),
                    trailing: InkWell(
                      onTap: () {
                        playindex = index;
                        setState(() {
                          isPlay = !isPlay;
                        });
                        isPlay
                            ? _player.play(files[index].path)
                            : _player.pause();
                      },
                      child: Icon(
                        playicon,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      isPlay? _player.pause():Null;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MusicApp(
                                    path: files[index].path,play: isPlay,
                                  )));
                    },
                  ));
                },
              ));
  }
}
