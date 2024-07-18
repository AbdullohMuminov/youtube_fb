import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UniversityScreen extends StatelessWidget {
  const UniversityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('University Collections')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Buildings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentScreen(collection: 'Buildings')),
              );
            }
          ),
          ListTile(
            title: const Text('Faculties'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentScreen(collection: 'Faculties')),
              );
            }
          ),
          ListTile(
            title: const Text('Students'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentScreen(collection: 'Students')),
              );
            }
          ),
        ],
      ),
    );
  }
}

class DocumentScreen extends StatelessWidget {
  final String collection;
  const DocumentScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final CollectionReference collectionReference = FirebaseFirestore.instance.collection(collection);

    return Scaffold(
      appBar: AppBar(title: Text('$collection Collection')),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionReference.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                // subtitle: Text(data['date']?.toDate().toString() ?? 'No Date'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDocument(context, collectionReference);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void addDocument(BuildContext context, CollectionReference collectionReference) {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Document'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await collectionReference.add({
                'name': nameController.text,
                'date': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
