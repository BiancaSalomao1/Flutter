// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:appeducafin/controllers/login_controller.dart';
import 'package:appeducafin/controllers/tarefa_controller.dart';
import 'package:flutter/material.dart';
import 'package:appeducafin/models/tarefa.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TarefaView extends StatefulWidget {
  const TarefaView({super.key});

  @override
  State<TarefaView> createState() => _TarefaViewState();
}

class _TarefaViewState extends State<TarefaView> {
  final ctrl = GetIt.I.get<TarefaController>();
  final ctrlLogin = GetIt.I.get<LoginController>();
  Widget campoTexto(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ctrl.addListener(() => setState(() {}));
    ctrlLogin.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Text('Tarefas', style: TextStyle(color: Colors.white)),
            ),
            FutureBuilder<String>(
              future: LoginController().usuarioLogado(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        ctrlLogin.logout(context);
                      },
                      icon: Icon(
                        Icons.exit_to_app,
                        size: 22,
                        color: Colors.white,
                      ),
                      label: Text(
                        snapshot.data.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ],
        ),
      ),

      //
      // BODY
      //
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: TarefaController().listar(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text('Não foi possível conectar.'));
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  final dados = snapshot.requireData;
                  if (dados.size > 0) {
                    return ListView.builder(
                      itemCount: dados.size,
                      itemBuilder: (context, index) {
                        String id = dados.docs[index].id;
                        dynamic item = dados.docs[index].data();
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.description),
                            title: Text(item['titulo']),
                            subtitle: Text(item['descricao']),
                            onTap: () {
                              ctrl.txtTitulo.text = item['titulo'];
                              ctrl.txtDescricao.text = item['descricao'];
                              salvarTarefa(context, uid: id);
                            },
                            onLongPress: () {
                              TarefaController().excluir(context, id);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('Nenhuma tarefa encontrada.'));
                  }
              }
            },
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          salvarTarefa(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //
  // ADICIONAR TAREFA
  //
  void salvarTarefa(context, {uid}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adicionar Tarefa"),
          content: SizedBox(
            height: 250,
            width: 300,
            child: Column(
              children: [
                campoTexto('Título', ctrl.txtTitulo, Icons.description),
                TextField(
                  controller: ctrl.txtDescricao,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
          actions: [
            TextButton(
              onPressed: () {
                ctrl.limparCampos();
                Navigator.pop(context);
              },

              child: Text('cancelar'),
            ),
            ElevatedButton(
              child: Text("salvar"),
              onPressed: () {
                var t = Tarefa(
                  LoginController().idUsuario().toString(),
                  ctrl.txtTitulo.text,
                  ctrl.txtDescricao.text,
                );

                ctrl.limparCampos();
                if (uid == null) {
                  ctrl.adicionar(context, t);
                } else {
                  ctrl.atualizar(context, uid, t);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
