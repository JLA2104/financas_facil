import 'package:flutter/material.dart';
import 'dart:math';
import '../data/movimentacoes_list.dart' as mov_list;

class GraficoDespesasPage extends StatelessWidget {
  const GraficoDespesasPage({Key? key}) : super(key: key);

  // calcula soma de despesas por categoria (valores negativos)
  Map<String, double> _calcularPorCategoria() {
    final Map<String, double> mapa = {};
    for (final m in mov_list.movimentacoes) {
      final valor = (m['valor'] as double);
      if (valor >= 0) continue; // só despesas
      final cat = (m['categoria'] as String?) ?? 'Outros';
      mapa[cat] = (mapa[cat] ?? 0) + valor.abs();
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final dados = _calcularPorCategoria();
    final total = dados.values.fold(0.0, (s, v) => s + v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas por Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (dados.isEmpty)
              Center(child: Text('Nenhuma despesa registrada'))
            else ...[
              SizedBox(
                height: 240,
                child: CustomPaint(
                  painter: _PieChartPainter(dados),
                  child: Container(),
                ),
              ),
              const SizedBox(height: 16),
              // legenda
              Expanded(
                child: ListView(
                  children: dados.entries.map((e) {
                    final pct = total > 0 ? (e.value / total) * 100 : 0.0;
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: _PieChartPainter.colorFor(e.key)),
                      title: Text(e.key),
                      trailing: Text('${e.value.toStringAsFixed(2).replaceAll('.', ',')} (${pct.toStringAsFixed(1)}%)'),
                    );
                  }).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  static final List<Color> _colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];

  _PieChartPainter(this.data);

  static Color colorFor(String key) {
    final idx = key.hashCode.abs() % _colors.length;
    return _colors[idx];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (s, v) => s + v);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = (size.shortestSide * 0.4);
    double startAngle = -pi / 2;

    data.forEach((k, v) {
      final sweep = total > 0 ? (v / total) * 2 * pi : 0.0;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colorFor(k);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);
      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
