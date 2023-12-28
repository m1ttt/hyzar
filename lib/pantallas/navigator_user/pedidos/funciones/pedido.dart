import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> obtenerDatosDePedidos(List<String> ids) async {
  final firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> documentos = [];
  for (String id in ids) {
    final doc = await firestore.collection('medicamentos').doc(id).get();
    if (doc.exists) {
      documentos.add(doc);
    }
  }

  return documentos;
}
