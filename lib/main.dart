import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Delete List Item',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SamplePage2(),
    );
  }
}

class SamplePage2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SamplePage2State();
}

class SamplePage2State extends State<SamplePage2> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  var _data = [];
  static int INSERTCARD = 0;
  static int UPDATECARD = 1;

  Future<void> InputDialog(BuildContext context, int state, int index) async {
    //処理が重い(?)からか、非同期処理にする
    var _nameController = TextEditingController();
    var _titleController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('input'),
            content: Form(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'title'),
                    controller: _titleController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'name'),
                    controller: _nameController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  //OKを押したあとの処理
                  String title = _titleController.text;
                  String name = _nameController.text;
                  setState(() {
                    int insertIndex = _data.length;
                    if (state == 0) {
                      _data.add(new ScheduleCardData(title, name));
                      _listKey.currentState.insertItem(insertIndex);
                    } else if (state == 1) {
                      ScheduleCardData removedItem = _data.removeAt(index);

                      // 削除アニメーションで利用されるウィジェットのビルダ関数
                      // 削除前のものと同じ描画内容にするといい感じに消える
                      AnimatedListRemovedItemBuilder builder =
                          (context, animation) {
                        return _buildItem(removedItem, animation);
                      };
                      _listKey.currentState.removeItem(index, builder);
                      _data.insert(index, new ScheduleCardData(title, name));
                      _listKey.currentState.insertItem(index);
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _data.length,
              itemBuilder:
                  (BuildContext context, int index, Animation animation) {
                return _buildItem(_data[index], animation);
              },
            ),
          ),
          ElevatedButton(
            child: const Text('add new schedule'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              InputDialog(context, INSERTCARD, 0);
              //add_schedule('test_text', 'test_subtitle');
            },
          ),
          ElevatedButton(
            child: const Text('refresh'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                HttpRequest res = new HttpRequest();
                res.select();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ScheduleCardData item, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.album),
              title: Text(item.title),
              subtitle: Text(item.name),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('Edit'),
                  onPressed: () {
                    InputDialog(context, UPDATECARD, _data.indexOf(item));
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    // 内部データを消す
                    var removeIndex = _data.indexOf(item);
                    ScheduleCardData removedItem = _data.removeAt(removeIndex);

                    // 削除アニメーションで利用されるウィジェットのビルダ関数
                    // 削除前のものと同じ描画内容にするといい感じに消える
                    AnimatedListRemovedItemBuilder builder =
                        (context, animation) {
                      return _buildItem(removedItem, animation);
                    };

                    // ウィジェット上から削除を実行する
                    _listKey.currentState.removeItem(removeIndex, builder);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCardData {
  String title;
  String name;
  ScheduleCardData(String title, String name) {
    this.title = title;
    this.name = name;
  }

  void setTitle(String titile) {
    this.title = title;
  }

  void setName(String name) {
    this.name = name;
  }
}

class HttpRequest {
  final uri_select = Uri.http('localhost:3000', '/select');

  HttpRequest() {}

  void select() async {
    final response = await http.get(uri_select);
    print(response.body);
  }
}
