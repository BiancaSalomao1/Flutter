import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appeducafin/views/home.dart';

class CriarUsuarioScreen extends StatefulWidget {
  @override
  _CriarUsuarioScreenState createState() => _CriarUsuarioScreenState();
}

class _CriarUsuarioScreenState extends State<CriarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController primeiroNomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController dataNascimentoController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    primeiroNomeController.dispose();
    sobrenomeController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    telefoneController.dispose();
    dataNascimentoController.dispose();
    super.dispose();
  }

  Future<int> _gerarProximoIdSequencial() async {
    final counterRef = FirebaseFirestore.instance.collection('counters').doc('users');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      int current = snapshot.exists ? snapshot.data()!['value'] ?? 0 : 0;
      transaction.set(counterRef, {'value': current + 1});
      return current + 1;
    });
  }

  void _salvarCadastro() async {
    if (_formKey.currentState!.validate()) {
      if (!_isChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirme que você não é um robô')),
        );
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

        String uid = userCredential.user!.uid;
        int idSequencial = await _gerarProximoIdSequencial();

        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'id': idSequencial,
          'primeiro_nome': primeiroNomeController.text.trim(),
          'sobrenome': sobrenomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'data_nascimento': dataNascimentoController.text.trim(),
          'criado_em': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário criado com sucesso!')),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String erro;
        if (e.code == 'email-already-in-use') {
          erro = 'Este email já está em uso.';
        } else if (e.code == 'invalid-email') {
          erro = 'Email inválido.';
        } else if (e.code == 'weak-password') {
          erro = 'A senha é muito fraca.';
        } else {
          erro = 'Erro ao registrar: ${e.code}';
        }

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erro'),
            content: Text(erro),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erro inesperado'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Usuário'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o email';
                  if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: primeiroNomeController,
                decoration: const InputDecoration(
                  labelText: 'Primeiro Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o primeiro nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sobrenomeController,
                decoration: const InputDecoration(
                  labelText: 'Sobrenome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o sobrenome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o telefone';
                  if (value.length < 10) return 'Telefone incompleto';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dataNascimentoController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a data de nascimento';
                  final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                  if (!datePattern.hasMatch(value)) return 'Data inválida. Use DD/MM/AAAA';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.length < 6) ? 'Senha muito curta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != senhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Text('I\'m not a robot'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarCadastro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
