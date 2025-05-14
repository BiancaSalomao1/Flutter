import 'package:appeducafin/models/tarefa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'login_controller.dart';

class TarefaController extends ChangeNotifier {
  var txtTitulo = TextEditingController();
  var txtDescricao = TextEditingController();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  adicionar(context, Tarefa t) {}

  atualizar(context, uid, Tarefa t) {}

  excluir(context, uid) {}

  Stream<QuerySnapshot> listar() {
    var resultado = db
        .collection('tarefas')
        .where('uid', isEqualTo: LoginController().idUsuario());

    return resultado.snapshots();
  }

  void limparCampos(){
    txtTitulo.clear();
    txtDescricao.clear();
  }
}