import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CRUDEoperation extends StatefulWidget {
  const CRUDEoperation({super.key});

  @override
  State<CRUDEoperation> createState() => _CRUDEoperationState();
}

class _CRUDEoperationState extends State<CRUDEoperation> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController positionC = TextEditingController();
  final TextEditingController searchC = TextEditingController();

  @override
  void dispose() {
    nameC.dispose();
    positionC.dispose();
    searchC.dispose();
    super.dispose();
  }

  final CollectionReference myItems = FirebaseFirestore.instance.collection("CRUDitems");

  Future<void> create() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Create User",
          condition: "Create",
          onPressed: () {
            String name = nameC.text;
            String position = positionC.text;
            addItems(name, position);
            Navigator.pop(context);
            nameC.clear();
            positionC.clear();
          },
        );
      },
    );
  }

  void addItems(String name, String position) {
    myItems.add({
      'name': name,
      'position': position,
    });
  }

  Future<void> update(DocumentSnapshot documentSnapshot) async {
    nameC.text = documentSnapshot['name'];
    positionC.text = documentSnapshot['position'];
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Update data",
          condition: "Update",
          onPressed: () async {
            String name = nameC.text;
            String position = positionC.text;
            await myItems.doc(documentSnapshot.id).update({
              'name': name,
              'position': position,
            });
            nameC.text = '';
            positionC.text = '';
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> delete(String id) async {
    await myItems.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
        content: Text("Deleted successfully"),
      ),
    );
  }

  String searchText = '';

  void onSearchChange(String value){
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: isSearchClick
            ? Container(
                margin: const EdgeInsets.fromLTRB(40, 10, 0, 10),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: onSearchChange,
                  controller: searchC,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 20, 30, 10),
                    hintText: "Search...",
                    isDense: true,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : const Text(
                "Firestore CRUD",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClick = !isSearchClick;
                if(!isSearchClick){
                  searchC.clear();
                  onSearchChange("");
                }
              });
            },
            icon: Icon(
              isSearchClick ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items = streamSnapshot.data!.docs.where((doc) => doc['name'].toLowerCase().contains(searchText.toLowerCase())).toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          documentSnapshot['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          documentSnapshot['position'],
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => update(documentSnapshot),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => delete(documentSnapshot.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: create,
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  Dialog myDialogBox({
    required String name,
    required String condition,
    required VoidCallback onPressed,
  }) =>
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: "Enter the name",
                  hintText: "eg. Abdulloh",
                ),
              ),
              TextField(
                controller: positionC,
                decoration: const InputDecoration(
                  labelText: "Enter the position",
                  hintText: "eg. Designer",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(condition),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
}
