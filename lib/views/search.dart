import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isLoading = false;

  Map<String, Map<String, dynamic>> _metas = {};
  StreamSubscription<QuerySnapshot>? _historySubscription;
  StreamSubscription<QuerySnapshot>? _savedSearchSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _historySubscription?.cancel();
    _savedSearchSubscription?.cancel();
    super.dispose();
  }

  void _initializeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        final metas = await _carregarMetas();
        if (mounted) {
          setState(() {
            _metas = metas;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<Map<String, Map<String, dynamic>>> _carregarMetas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};

      debugPrint('=== CARREGANDO METAS ===');

      // Carrega TODAS as metas do usuário
      final snapshot =
          await FirebaseFirestore.instance
              .collection('goals')
              .where('userId', isEqualTo: user.uid)
              .get();

      final mapa = <String, Map<String, dynamic>>{};
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Validação robusta dos dados
          final category = data['category']?.toString() ?? 'Meta Sem Nome';
          final finalAmount = _parseDouble(data['finalAmount']);
          final monthly = _parseDouble(data['monthly']);
          final months = _parseInt(data['months']);
          final deleted = _parseBool(data['deleted']);

          mapa[doc.id] = {
            'category': category,
            'finalAmount': finalAmount,
            'monthly': monthly,
            'months': months,
            'deleted': deleted,
          };

          debugPrint(
            'Meta carregada: ${doc.id} - $category (deleted: $deleted)',
          );
        } catch (e) {
          debugPrint('Erro ao processar meta ${doc.id}: $e');
          // Continua com a próxima meta em caso de erro
        }
      }

      debugPrint('Total de metas carregadas: ${mapa.length}');
      debugPrint(
        'Metas vigentes: ${mapa.values.where((m) => m['deleted'] == false).length}',
      );
      debugPrint(
        'Metas excluídas: ${mapa.values.where((m) => m['deleted'] == true).length}',
      );
      debugPrint('=======================');

      return mapa;
    } catch (e) {
      debugPrint('Erro ao carregar metas: $e');
      return {};
    }
  }

  // Funções auxiliares para parsing seguro
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  void _salvarPesquisa() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não está logado')),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('pesquisas_salvas').add({
        'query': _query,
        'filtro': _filtro,
        'excluidas': _excluidas,
        'data': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesquisa salva com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar pesquisa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar pesquisa')),
        );
      }
    }
  }

  Stream<QuerySnapshot>? _getHistoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      return FirebaseFirestore.instance.collection('history').snapshots();
    } catch (e) {
      debugPrint('Erro ao criar stream de histórico: $e');
      return null;
    }
  }

  Stream<QuerySnapshot>? _getSavedSearchStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      return FirebaseFirestore.instance
          .collection('pesquisas_salvas')
          .where('userId', isEqualTo: user.uid)
          .orderBy('data', descending: true)
          .limit(10)
          .snapshots();
    } catch (e) {
      debugPrint('Erro ao criar stream de pesquisas salvas: $e');
      return FirebaseFirestore.instance
          .collection('pesquisas_salvas')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    }
  }

  List<Map<String, dynamic>> _filtrarResultados(QuerySnapshot snapshot) {
    final resultados = <Map<String, dynamic>>[];

    try {
      debugPrint('=== INICIANDO FILTRAGEM ===');
      debugPrint('Filtro atual: $_filtro');
      debugPrint('Busca excluídas: $_excluidas');
      debugPrint('Query: "$_query"');
      debugPrint('Documentos de histórico: ${snapshot.docs.length}');
      debugPrint('Total de metas carregadas: ${_metas.length}');

      // Processa todas as metas (independente do histórico)
      for (var entry in _metas.entries) {
        final goalId = entry.key;
        final metaInfo = entry.value;

        try {
          final metaDeletada = metaInfo['deleted'] == true;

          debugPrint('Processando meta $goalId:');
          debugPrint('  - Nome: ${metaInfo['category']}');
          debugPrint('  - Deletada: $metaDeletada');
          debugPrint('  - Filtro excluídas: $_excluidas');

          // FILTRO 1: Status (vigente/excluída)
          if (_excluidas != metaDeletada) {
            debugPrint('  - FILTRADA por status');
            continue;
          }

          // Busca histórico correspondente
          Map<String, dynamic>? historyDoc;
          List<Map<String, dynamic>> items = [];

          try {
            historyDoc =
                snapshot.docs
                    .where((doc) => doc.id == goalId)
                    .map((doc) => doc.data() as Map<String, dynamic>?)
                    .where((data) => data != null)
                    .cast<Map<String, dynamic>>()
                    .firstOrNull;

            if (historyDoc != null) {
              items =
                  (historyDoc['items'] as List<dynamic>? ?? [])
                      .whereType<Map<String, dynamic>>()
                      .toList();
              debugPrint('  - Encontrou histórico com ${items.length} itens');
            } else {
              debugPrint('  - Sem histórico');
            }
          } catch (e) {
            debugPrint('  - Erro ao buscar histórico: $e');
          }

          // FILTRO 2: Query de busca
          if (!_matchesQuery(metaInfo, items)) {
            debugPrint('  - FILTRADA por query');
            continue;
          }

          debugPrint('  - INCLUÍDA nos resultados');
          resultados.add({'goalId': goalId, 'items': items, 'meta': metaInfo});
        } catch (e) {
          debugPrint('Erro ao processar meta $goalId: $e');
        }
      }

      // Ordenação
      _ordenarResultados(resultados);

      debugPrint('=== RESULTADO FINAL ===');
      debugPrint('Total de resultados: ${resultados.length}');
      for (var i = 0; i < resultados.length; i++) {
        final r = resultados[i];
        debugPrint(
          '$i: ${r['goalId']} - ${r['meta']['category']} (${r['meta']['deleted'] ? 'excluída' : 'vigente'})',
        );
      }
      debugPrint('=======================');
    } catch (e) {
      debugPrint('Erro geral na filtragem: $e');
    }

    return resultados;
  }

  bool _matchesQuery(
    Map<String, dynamic> metaInfo,
    List<Map<String, dynamic>> items,
  ) {
    if (_query.isEmpty) return true;

    final queryLower = _query.toLowerCase().trim();
    if (queryLower.isEmpty) return true;

    // Busca no nome da meta
    final nomeMeta = metaInfo['category']?.toString().toLowerCase() ?? '';
    if (nomeMeta.contains(queryLower)) {
      debugPrint('    - Match no nome: "$nomeMeta" contém "$queryLower"');
      return true;
    }

    // Busca nos itens do histórico
    for (var item in items) {
      try {
        final timestampValue = item['timestamp'];
        String dataStr = '';

        if (timestampValue is Timestamp) {
          final date = timestampValue.toDate();
          dataStr = '${date.day}/${date.month}/${date.year}';
        } else if (timestampValue is String) {
          dataStr = timestampValue;
        }

        final monthStr = (item['month'] ?? '').toString();

        if (dataStr.toLowerCase().contains(queryLower) ||
            monthStr.toLowerCase().contains(queryLower)) {
          debugPrint(
            '    - Match no histórico: "$dataStr" ou "$monthStr" contém "$queryLower"',
          );
          return true;
        }
      } catch (e) {
        debugPrint('    - Erro ao verificar item do histórico: $e');
      }
    }

    return false;
  }

  void _ordenarResultados(List<Map<String, dynamic>> resultados) {
    resultados.sort((a, b) {
      final aItems = a['items'] as List<Map<String, dynamic>>;
      final bItems = b['items'] as List<Map<String, dynamic>>;

      switch (_filtro) {
        case 'data':
          final aDate = _getLastConfirmedTimestamp(aItems);
          final bDate = _getLastConfirmedTimestamp(bItems);
          return bDate.compareTo(aDate);

        case 'relevancia':
          final aMax = _getMaxConfirmedAmount(aItems);
          final bMax = _getMaxConfirmedAmount(bItems);
          return bMax.compareTo(aMax);

        case 'alfabetica':
          final aNome = a['meta']['category']?.toString() ?? '';
          final bNome = b['meta']['category']?.toString() ?? '';
          return aNome.compareTo(bNome);

        default:
          return 0;
      }
    });
  }

  Timestamp _getLastConfirmedTimestamp(List<Map<String, dynamic>> items) {
    final datas = <DateTime>[];

    for (var item in items) {
      try {
        final timestampValue = item['timestamp'];
        DateTime? dateTime;

        if (timestampValue is Timestamp) {
          dateTime = timestampValue.toDate();
        } else if (timestampValue is String) {
          dateTime = DateTime.tryParse(timestampValue);
        }

        if (dateTime != null) {
          datas.add(dateTime);
        }
      } catch (e) {
        debugPrint('Erro ao processar timestamp: $e');
      }
    }

    return datas.isEmpty
        ? Timestamp(0, 0)
        : Timestamp.fromDate(datas.reduce((a, b) => a.isAfter(b) ? a : b));
  }

  double _getMaxConfirmedAmount(List<Map<String, dynamic>> items) {
    try {
      final confirmados =
          items.where((e) => _parseBool(e['confirmed'])).toList();

      if (confirmados.isEmpty) return 0.0;

      return confirmados
          .map((e) => _parseDouble(e['amount']))
          .reduce((a, b) => a > b ? a : b);
    } catch (e) {
      debugPrint('Erro ao calcular valor máximo: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesquisar Metas')),
        body: const Center(
          child: Text(
            'Usuário não está logado',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Metas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      setState(() => _isLoading = true);
                      try {
                        final metas = await _carregarMetas();
                        if (mounted) {
                          setState(() {
                            _metas = metas;
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Metas recarregadas!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao recarregar: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      }
                    },
          ),
          TextButton(onPressed: _salvarPesquisa, child: const Text('Salvar')),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                            DropdownMenuItem(
                              value: 'data',
                              child: Text('Data'),
                            ),
                            DropdownMenuItem(
                              value: 'alfabetica',
                              child: Text('Alfabética'),
                            ),
                            DropdownMenuItem(
                              value: 'relevancia',
                              child: Text('Relevância'),
                            ),
                          ],
                          onChanged:
                              (value) => setState(() => _filtro = value!),
                        ),
                        const Spacer(),
                        Switch(
                          value: _excluidas,
                          onChanged: (v) => setState(() => _excluidas = v),
                        ),
                        const Text('Excluídas'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getHistoryStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar dados: ${snapshot.error}',
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final resultados = _filtrarResultados(snapshot.data!);

                        if (resultados.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _excluidas
                                      ? Icons.cancel_outlined
                                      : Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _excluidas
                                      ? 'Nenhuma meta excluída encontrada'
                                      : 'Nenhuma meta vigente encontrada',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (_query.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Busca: "$_query"',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: resultados.length,
                          itemBuilder: (context, index) {
                            final dados = resultados[index];
                            final meta = dados['meta'] as Map<String, dynamic>;
                            final items =
                                (dados['items'] as List<Map<String, dynamic>>);

                            final nome =
                                meta['category']?.toString() ?? 'Sem nome';
                            final valorFinal = _parseDouble(
                              meta['finalAmount'],
                            );
                            final timestamp = _getLastConfirmedTimestamp(items);
                            final max = _getMaxConfirmedAmount(items);
                            final confirmados =
                                items
                                    .where((i) => _parseBool(i['confirmed']))
                                    .length;
                            final excluidos =
                                items
                                    .where((i) => !_parseBool(i['confirmed']))
                                    .length;
                            final temHistorico = items.isNotEmpty;
                            final valorMensal = _parseDouble(meta['monthly']);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _excluidas
                                          ? Colors.red.shade100
                                          : Colors.green.shade100,
                                  child: Icon(
                                    _excluidas
                                        ? Icons.cancel
                                        : Icons.check_circle,
                                    color:
                                        _excluidas ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (temHistorico &&
                                        timestamp.seconds > 0) ...[
                                      Text(
                                        '${_excluidas ? "Último excluído" : "Último aporte"}: ${timestamp.toDate().day.toString().padLeft(2, '0')}/${timestamp.toDate().month.toString().padLeft(2, '0')}/${timestamp.toDate().year}',
                                      ),
                                      if (max > 0)
                                        Text(
                                          '${_excluidas ? "Maior excluído" : "Maior aporte"}: R\$${max.toStringAsFixed(2)}',
                                        ),
                                    ] else ...[
                                      Text(
                                        temHistorico
                                            ? 'Sem aportes registrados'
                                            : 'Sem histórico disponível',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      if (valorMensal > 0)
                                        Text(
                                          'Valor mensal: R\$${valorMensal.toStringAsFixed(2)}',
                                        ),
                                    ],
                                    Text(
                                      'Meta: R\$${valorFinal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (temHistorico)
                                      Text(
                                        'Confirmados: $confirmados | Excluídos: $excluidos',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _excluidas
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _excluidas
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                  child: Text(
                                    _excluidas ? 'Excluída' : 'Vigente',
                                    style: TextStyle(
                                      color:
                                          _excluidas
                                              ? Colors.red
                                              : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
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
                      stream: _getSavedSearchStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar pesquisas: ${snapshot.error}',
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhuma pesquisa salva.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.history, size: 20),
                              title: Text(
                                'Pesquisa: "${data['query'] ?? ''}"',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                'Filtro: ${data['filtro'] ?? ''} | Excluídas: ${data['excluidas'] ?? false}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                setState(() {
                                  _query = data['query']?.toString() ?? '';
                                  _filtro =
                                      data['filtro']?.toString() ?? 'data';
                                  _excluidas = data['excluidas'] ?? false;
                                  _searchController.text = _query;
                                });
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('pesquisas_salvas')
                                        .doc(doc.id)
                                        .delete();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Erro ao deletar: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
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
