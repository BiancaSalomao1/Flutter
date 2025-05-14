import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    primeiroNomeController.dispose();
    sobrenomeController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
} catch (e) {
  // Erros não Firebase
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Erro inesperado'),
      content: Text(e.toString()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: primeiroNomeController,
                decoration: const InputDecoration(labelText: 'Primeiro Nome', border: OutlineInputBorder()),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o primeiro nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sobrenomeController,
                decoration: const InputDecoration(labelText: 'Sobrenome', border: OutlineInputBorder()),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o sobrenome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                validator: (value) =>
                    (value == null || value.length < 6) ? 'Senha muito curta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Senha', border: OutlineInputBorder()),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
