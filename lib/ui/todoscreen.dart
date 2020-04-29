import 'package:flutter/material.dart';
import 'package:to_do_app/model/todo_item.dart';
import 'package:to_do_app/util/datbase_client.dart';
import 'package:to_do_app/util/dateformatter.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  var db= new DatabaseHelper();
  final List<ToDoItem> _itemList=<ToDoItem>[];


  @override
  void initState(){
    super.initState();
    _readTodoList();
  }

  void _handleSubmit(String text) async{
    _textEditingController.clear();
    ToDoItem toDoItem=new ToDoItem(text, dateFormatted());
    int savedItemId= await db.saveItem(toDoItem);
    ToDoItem addedItem=await db.getItem(savedItemId);
    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  final TextEditingController _textEditingController=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse:false,
                  itemCount: _itemList.length,
                  itemBuilder: (context,int index){
                  return Card(
                  color:Colors.white10,
                    child: new ListTile(
                      title: _itemList[index] ,
                      onLongPress: ()=>_updateItem(_itemList[index],index),
                      trailing: new Listener(
                        key: new Key(_itemList[index].itemName),
                        child: new Icon(Icons.remove_circle,
                        color: Colors.redAccent,),
                        onPointerDown: (pointerEvent)=>
                            _deleteToDo(_itemList[index].id,index),
                      ),
                    ),
                  );

                  }),),

          new Divider(
            height: 1.0,

          )
        ],

      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add item',
          backgroundColor: Colors.redAccent,
          child: new ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content: new Row (
        children: <Widget>[

          new Expanded(

              child: new TextField(

                controller: _textEditingController,
                  autofocus: true,
                decoration: new InputDecoration(
                  labelText: "item",
                  labelStyle: new TextStyle(
                    fontSize: 22.0,
                  ),
                  hintText: "eg. Buy Stuffs",
                  icon: new Icon(Icons.note_add)
                ),
              ))

        ],

      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        new FlatButton(onPressed: ()=> Navigator.pop(context),
            child: Text("Cancel")),
      ],
    );
    showDialog(context: context,
        builder: (context){
      return alert;
        });
  }

  _readTodoList() async{
    List items = await db.getItems();
    items.forEach((item){
      setState(() {
        _itemList.add(ToDoItem.map((item)));
      });

    });
  }

  _deleteToDo(int id,int index) async {
await db.deleteItem(id);
setState(() {
  _itemList.removeAt(index);

});
  }

  _updateItem(ToDoItem item, int index) {

    var alert= new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                labelText: "Item",
                hintText: "eg. buy stuff",
                icon: new Icon(Icons.update),
              ),

            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async{
       ToDoItem newItemUpdated = ToDoItem.fromMap(
          {"itemName": _textEditingController.text,
            "dateCreated": dateFormatted(),
            "id": item.id,
          }
      );

      _handleSubmittedUpdate(index,item);
      await db.updateItem(newItemUpdated);
      setState(() {
        _readTodoList();

      });
      Navigator.pop(context);
    },
             child: new Text("Update")
        ),
        new FlatButton(onPressed: ()=>Navigator.pop(context),
            child: new Text("Cancel"),
        )
      ],
    );

    showDialog(context: context,builder: (BuildContext context){
      return alert;
    });

  }

  void _handleSubmittedUpdate(int index, item) {

    setState(() {

      _itemList.removeWhere((element){
      return  _itemList[index].itemName==item.itemName;
      });

    });
  }
}
