import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key});

  @override
  State<PesquisaPage> createState() => _PesquisaPageState();
}

class _PesquisaPageState extends State<PesquisaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filtro = 'data';
  String _query = '';
  bool _excluidas = false;

  Map<String, Map<String, dynamic>> _metas = {};

  @override
  void initState() {
    super.initState();
    _carregarMetas().then((mapa) => setState(() => _metas = mapa));
  }

  Future<Map<String, Map<String, dynamic>>> _carregarMetas() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('goals').get();
      final mapa = <String, Map<String, dynamic>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        mapa[doc.id] = {
          'category': data['category']?.toString() ?? 'Metas Não Personalizadas',
          'finalAmount': (data['finalAmount'] ?? 0).toDouble(),
          'monthly': (data['monthly'] ?? 0).toDouble(),
          'months': data['months'] ?? 0,
          'deleted': data['deleted'] ?? false,
        };
      }
      return mapa;
    } catch (_) {
      return {};
    }
  }

  void _salvarPesquisa() async {
    try {
      await FirebaseFirestore.instance.collection('pesquisas_salvas').add({
        'query': _query,
        'filtro': _filtro,
        'excluidas': _excluidas,
        'data': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesquisa salva com sucesso!')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar pesquisa')),
      );
    }
  }

  Stream<QuerySnapshot> _filtrarStream() {
    return FirebaseFirestore.instance.collection('history').snapshots();
  }

  List<Map<String, dynamic>> _filtrarResultados(QuerySnapshot snapshot) {
    final resultados = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final goalId = doc.id;
      final items = (data['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
      final metaInfo = _metas[goalId];
      if (metaInfo == null) continue;

      final metaDeletada = metaInfo['deleted'] == true;

      if (_excluidas && !metaDeletada) continue;
      if (!_excluidas && metaDeletada) continue;

      if (_query.isNotEmpty) {
        final nomeMeta = metaInfo['category']?.toString().toLowerCase() ?? '';
        final match = items.any((item) {
          final dataStr = (item['timestamp'] as Timestamp?)?.toDate().toString().toLowerCase() ?? '';
          final monthStr = (item['month'] ?? '').toString().toLowerCase();
          return dataStr.contains(_query.toLowerCase()) ||
              monthStr.contains(_query.toLowerCase()) ||
              nomeMeta.contains(_query.toLowerCase());
        });
        if (!match) continue;
      }

      resultados.add({
        'goalId': goalId,
        'items': items,
        'meta': metaInfo,
      });
    }

    if (_excluidas) {
      final idsComHistorico = snapshot.docs.map((d) => d.id).toSet();
      final excluidasSemHistorico = _metas.entries.where((entry) {
        return entry.value['deleted'] == true && !idsComHistorico.contains(entry.key);
      });
      for (var entry in excluidasSemHistorico) {
        resultados.add({
          'goalId': entry.key,
          'items': [],
          'meta': entry.value,
        });
      }
    }

    resultados.sort((a, b) {
      final aItems = a['items'] as List<Map<String, dynamic>>;
      final bItems = b['items'] as List<Map<String, dynamic>>;

      if (_filtro == 'data') {
        final aDate = _getLastConfirmedTimestamp(aItems);
        final bDate = _getLastConfirmedTimestamp(bItems);
        return bDate.compareTo(aDate);
      } else if (_filtro == 'relevancia') {
        final aMax = _getMaxConfirmedAmount(aItems);
        final bMax = _getMaxConfirmedAmount(bItems);
        return bMax.compareTo(aMax);
      } else if (_filtro == 'alfabetica') {
        final aNome = a['meta']['category'] ?? '';
        final bNome = b['meta']['category'] ?? '';
        return aNome.toString().compareTo(bNome.toString());
      }
      return 0;
    });

    return resultados;
  }

  Timestamp _getLastConfirmedTimestamp(List<Map<String, dynamic>> items) {
    final datas = items.map((e) => (e['timestamp'] as Timestamp?)?.toDate()).whereType<DateTime>().toList();
    return datas.isEmpty ? Timestamp(0, 0) : Timestamp.fromDate(datas.reduce((a, b) => a.isAfter(b) ? a : b));
  }

  double _getMaxConfirmedAmount(List<Map<String, dynamic>> items) {
    final valores = items.map((e) => (e['amount'] ?? 0).toDouble()).toList();
    return valores.isEmpty ? 0 : valores.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Metas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () async {
            final metas = await _carregarMetas();
            setState(() => _metas = metas);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Metas recarregadas!')));
          }),
          TextButton(onPressed: _salvarPesquisa, child: const Text('Salvar')),
          TextButton(onPressed: () {
            _searchController.clear();
            setState(() => _query = '');
          }, child: const Text('Limpar')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar metas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Ordenar por:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filtro,
                  items: const [
                    DropdownMenuItem(value: 'data', child: Text('Data')),
                    DropdownMenuItem(value: 'alfabetica', child: Text('Alfabética')),
                    DropdownMenuItem(value: 'relevancia', child: Text('Relevância')),
                  ],
                  onChanged: (value) => setState(() => _filtro = value!),
                ),
                const Spacer(),
                Switch(value: _excluidas, onChanged: (v) => setState(() => _excluidas = v)),
                const Text('Excluídas'),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: _filtrarStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final resultados = _filtrarResultados(snapshot.data!);
                if (resultados.isEmpty) {
                  return Center(child: Text(_excluidas ? 'Nenhuma meta excluída encontrada' : 'Nenhuma meta vigente encontrada'));
                }
                return ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final dados = resultados[index];
                    final meta = dados['meta'];
                    final goalId = dados['goalId'];
                    final items = (dados['items'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];


                    final nome = meta['category'] ?? 'Sem nome';
                    final valorFinal = (meta['finalAmount'] ?? 0.0).toDouble();
                    final timestamp = _getLastConfirmedTimestamp(items);
                    final max = _getMaxConfirmedAmount(items);
                    final dt = timestamp.toDate();
                    final confirmados = items.where((i) => i['confirmed'] == true).length;
                    final excluidos = items.where((i) => i['confirmed'] == false).length;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _excluidas ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(_excluidas ? Icons.cancel : Icons.check_circle,
                              color: _excluidas ? Colors.red : Colors.green),
                        ),
                        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (timestamp.seconds > 0)
                              Text('${_excluidas ? "Último excluído" : "Último aporte"}: ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'),
                            Text('${_excluidas ? "Maior excluído" : "Maior aporte"}: R\$${max.toStringAsFixed(2)}'),
                            Text('Meta: R\$${valorFinal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Confirmados: $confirmados | Excluídos: $excluidos', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _excluidas ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _excluidas ? Colors.red : Colors.green),
                          ),
                          child: Text(_excluidas ? 'Excluída' : 'Vigente',
                              style: TextStyle(color: _excluidas ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesquisas_salvas')
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma pesquisa salva.', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 20),
                      title: Text('Pesquisa: "${data['query']}"', style: const TextStyle(fontSize: 14)),
                      subtitle: Text('Filtro: ${data['filtro']} | Excluídas: ${data['excluidas']}', style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        setState(() {
                          _query = data['query'];
                          _filtro = data['filtro'];
                          _excluidas = data['excluidas'];
                          _searchController.text = data['query'];
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => FirebaseFirestore.instance.collection('pesquisas_salvas').doc(doc.id).delete(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
