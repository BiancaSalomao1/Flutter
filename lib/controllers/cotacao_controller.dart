//  import 'dart:convert';


// // class CotacaoController {
//  Future<CotacaoModel?> fetchCotacao(String ticker) async {
// try {
//   final response = await http.get(Uri.parse(url));
//   if (response.statusCode == 200) {
//     return CotacaoModel.fromJson(jsonDecode(response.body));
//   } else {
//     return null;
//   }
// } catch (e) {
//   print('Erro ao buscar cotação: $e');
// }
// }