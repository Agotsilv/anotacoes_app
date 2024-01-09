import 'package:anotacoes_app/helper/AnotacaoHelper.dart';
import 'package:anotacoes_app/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  List<Anotacao> _anotacoes = [];

  final _db = AnotacaoHelper();

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String? textSalvar = "";
    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textSalvar = "Salvar";
    } else {
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textSalvar = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textSalvar Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: "Titulo", hintText: "Informa o titulo..."),
              ),
              TextField(
                controller: _descricaoController,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: "Descrição", hintText: "Informa a Descrição..."),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => {
                if (textSalvar == "Salvar")
                  {_salvarAnotacao()}
                else
                  {
                    _atualizarAnotacao(anotacao?.id, _tituloController.text,
                        _descricaoController.text)
                  },
                Navigator.pop(context)
              },
              child: Text("$textSalvar"),
            )
          ],
        );
      },
    );
  }

  _recuperarAnotacoes() async {
    List resultado = await _db.recuperarAnotacoes();
    List<Anotacao> anotacoesTemp = [];

    for (var i in resultado) {
      Anotacao anotacao = Anotacao.fromMap(i);
      anotacoesTemp.add(anotacao);
    }

    setState(() {
      _anotacoes = anotacoesTemp;
    });
    anotacoesTemp = [];
  }

  _salvarAnotacao() async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    // ignore: unused_local_variable
    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    await _db.salvarAnotacao(anotacao);
    _descricaoController.clear();
    _recuperarAnotacoes();
  }

  _formatarData(String? data) {
    initializeDateFormatting("pt_BR");
    // var formatData = DateFormat('DD/MMMM/yyyy');

    var formatData = DateFormat.yMMMd('pt_BR');
    DateTime dataConvertida = DateTime.parse(data!);
    String dataFormatada = formatData.format(dataConvertida);
    return dataFormatada;
  }

  _deletatAnotacao(int? index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Deseja Deletar essa anotação ?"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => {
                _db.deletaAnotacoes(index!),
                _recuperarAnotacoes(),
                Navigator.pop(context)
              },
              child: const Text("Deletar"),
            )
          ],
        );
      },
    );
  }

  _atualizarAnotacao(int? id, String titulo, String desc) async {
    await _db.atualizarAnotacao(id!, titulo, desc);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index) {
                  final item = _anotacoes[index];

                  return Card(
                    child: ListTile(
                      title: Text("${item.titulo}"),
                      subtitle: Text(
                          "${_formatarData(item.data)} - ${item.descricao}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _exibirTelaCadastro(anotacao: item);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 25),
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _deletatAnotacao(item.id);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
