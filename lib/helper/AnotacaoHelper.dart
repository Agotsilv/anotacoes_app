import 'package:path/path.dart';
import 'package:anotacoes_app/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';

class AnotacaoHelper {
  static const String nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDb();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE anotacao("
        " id integer primary key autoincrement,"
        "titulo varchar,"
        "descricao varchar,"
        "data DATATIME)";

    await db.execute(sql);
  }

  inicializarDb() async {
    final caminhoBancoDeDados = await getDatabasesPath();
    final localBancoDeDados = join(caminhoBancoDeDados, "banco_anotacoes.db");

    var db =
        await openDatabase(localBancoDeDados, version: 1, onCreate: _onCreate);
    return db;
  }

  salvarAnotacao(Anotacao anotacao) async {
    var bancoDeDados = await db;
    int id = await bancoDeDados.insert(nomeTabela, anotacao.toMap());
    return id;
  }

  recuperarAnotacoes() async {
    var bancoDeDados = await db;
    String sql = "SELECT * FROM anotacao ORDER BY data DESC";
    List anotacoes = await bancoDeDados.rawQuery(sql);
    return anotacoes;
  }

  deletaAnotacoes(int id) async {
    var bancoDeDados = await db;
    String sql = "DELETE FROM anotacao WHERE id = $id";
    return await bancoDeDados.rawQuery(sql);
  }

  Future atualizarAnotacao(int id, String titulo, String desc) async {
    var bancoDeDados = await db;
    return await bancoDeDados.rawUpdate(
      'UPDATE anotacao SET titulo = ?, descricao = ? WHERE id = ?',
      [titulo, desc, id],
    );
  }
}
