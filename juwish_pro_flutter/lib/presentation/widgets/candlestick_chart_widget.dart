import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CandleModel {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const CandleModel({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close >= open;
}

class CandlestickChartWidget extends StatefulWidget {
  final String symbol;
  final double basePrice;
  final double height;
  final bool isJwc;

  const CandlestickChartWidget({
    super.key,
    required this.symbol,
    required this.basePrice,
    this.height = 280,
    this.isJwc = false,
  });

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  String _activeTimeframe = '1D';
  bool _isLineChart = false;
  List<CandleModel> _candles = [];
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _generateCandles();
  }

  @override
  void didUpdateWidget(covariant CandlestickChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol ||
        oldWidget.basePrice != widget.basePrice) {
      _generateCandles();
    }
  }

  void _generateCandles() {
    final rand = Random(widget.symbol.hashCode + _activeTimeframe.hashCode);
    final count = 35;
    double current = widget.basePrice * 0.94;
    final List<CandleModel> list = [];

    for (int i = 0; i < count; i++) {
      final change = (rand.nextDouble() - 0.46) * (widget.basePrice * 0.035);
      final open = current;
      final close =
          (open + change).clamp(widget.basePrice * 0.7, widget.basePrice * 1.5);
      final high =
          max(open, close) + rand.nextDouble() * (widget.basePrice * 0.015);
      final low =
          min(open, close) - rand.nextDouble() * (widget.basePrice * 0.015);
      final volume =
          (rand.nextDouble() * 50000 + 10000) * (widget.isJwc ? 2.5 : 1.0);

      list.add(CandleModel(
        time: DateTime.now().subtract(Duration(hours: count - i)),
        open: open,
        high: high,
        low: max(0.001, low),
        close: close,
        volume: volume,
      ));
      current = close;
    }
    setState(() {
      _candles = list;
      _hoverIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCandle = _hoverIndex != null && _hoverIndex! < _candles.length
        ? _candles[_hoverIndex!]
        : (_candles.isNotEmpty ? _candles.last : null);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderHighlight),
      ),
      child: Column(
        children: [
          // Header Bar: Timeframes & Mode Toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ['1D', '1W', '1M', '1Y', 'ALL'].map((tf) {
                  final isSelected = _activeTimeframe == tf;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeTimeframe = tf);
                      _generateCandles();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.gold.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.gold : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.gold
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    tooltip: _isLineChart ? 'Candlestick View' : 'Line View',
                    icon: Icon(
                      _isLineChart ? Icons.candlestick_chart : Icons.show_chart,
                      color: AppTheme.gold,
                    ),
                    onPressed: () =>
                        setState(() => _isLineChart = !_isLineChart),
                  ),
                ],
              ),
            ],
          ),

          // OHLC details ribbon
          if (activeCandle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOhlcStat('O', activeCandle.open),
                  _buildOhlcStat('H', activeCandle.high),
                  _buildOhlcStat('L', activeCandle.low),
                  _buildOhlcStat('C', activeCandle.close, isHighlight: true),
                  _buildOhlcStat('Vol', activeCandle.volume, isVolume: true),
                ],
              ),
            ),

          // Interactive Chart Canvas
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx;
                final candleWidth = box.size.width / _candles.length;
                final index = (localX / candleWidth)
                    .clamp(0, _candles.length - 1)
                    .toInt();
                setState(() => _hoverIndex = index);
              },
              onHorizontalDragEnd: (_) {
                setState(() => _hoverIndex = null);
              },
              child: CustomPaint(
                painter: _FinancialChartPainter(
                  candles: _candles,
                  isLineChart: _isLineChart,
                  hoverIndex: _hoverIndex,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOhlcStat(String label, double value,
      {bool isHighlight = false, bool isVolume = false}) {
    String formatted;
    if (isVolume) {
      formatted = '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value < 10) {
      formatted = value.toStringAsFixed(4);
    } else {
      formatted = value.toStringAsFixed(2);
    }

    return Text(
      '$label: $formatted',
      style: TextStyle(
        fontSize: 10,
        fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
        color: isHighlight ? AppTheme.gold : AppTheme.textSecondary,
      ),
    );
  }
}

class _FinancialChartPainter extends CustomPainter {
  final List<CandleModel> candles;
  final bool isLineChart;
  final int? hoverIndex;

  _FinancialChartPainter({
    required this.candles,
    required this.isLineChart,
    this.hoverIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final candleWidth = size.width / candles.length;
    final chartHeight = size.height * 0.75;
    final volumeHeight = size.height * 0.22;

    double minPrice = candles.map((c) => c.low).reduce(min);
    double maxPrice = candles.map((c) => c.high).reduce(max);
    if (maxPrice == minPrice) maxPrice += 1.0;

    double maxVolume = candles.map((c) => c.volume).reduce(max);
    if (maxVolume <= 0) maxVolume = 1.0;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderHighlight.withOpacity(0.35)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 3; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (isLineChart) {
      // Line Chart Path
      final linePaint = Paint()
        ..color = AppTheme.gold
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < candles.length; i++) {
        final x = i * candleWidth + (candleWidth / 2);
        final normalizedY =
            (candles[i].close - minPrice) / (maxPrice - minPrice);
        final y = chartHeight - (normalizedY * chartHeight);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);

      // Area gradient fill
      final fillPath = Path.from(path)
        ..lineTo(
            (candles.length - 1) * candleWidth + (candleWidth / 2), chartHeight)
        ..lineTo(candleWidth / 2, chartHeight)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.gold.withOpacity(0.3),
            AppTheme.gold.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

      canvas.drawPath(fillPath, fillPaint);
    } else {
      // Candlestick Body & Wicks
      for (int i = 0; i < candles.length; i++) {
        final c = candles[i];
        final isBullish = c.isBullish;
        final color = isBullish ? AppTheme.greenBullish : AppTheme.redBearish;

        final candlePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final wickPaint = Paint()
          ..color = color
          ..strokeWidth = 1.2;

        final xCenter = i * candleWidth + (candleWidth / 2);

        // Wick
        final highY = chartHeight -
            ((c.high - minPrice) / (maxPrice - minPrice) * chartHeight);
        final lowY = chartHeight -
            ((c.low - minPrice) / (maxPrice - minPrice) * chartHeight);
        canvas.drawLine(
            Offset(xCenter, highY), Offset(xCenter, lowY), wickPaint);

        // Body
        final openY = chartHeight -
            ((c.open - minPrice) / (maxPrice - minPrice) * chartHeight);
        final closeY = chartHeight -
            ((c.close - minPrice) / (maxPrice - minPrice) * chartHeight);
        final topY = min(openY, closeY);
        final bodyHeight = max(1.5, (openY - closeY).abs());

        final bodyRect = Rect.fromCenter(
          center: Offset(xCenter, topY + bodyHeight / 2),
          width: max(2.5, candleWidth * 0.7),
          height: bodyHeight,
        );
        canvas.drawRRect(
            RRect.fromRectAndRadius(bodyRect, const Radius.circular(1.5)),
            candlePaint);
      }
    }

    // Volume bars
    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final color = c.isBullish
          ? AppTheme.greenBullish.withOpacity(0.4)
          : AppTheme.redBearish.withOpacity(0.4);

      final barPaint = Paint()..color = color;
      final xCenter = i * candleWidth + (candleWidth / 2);
      final barH = (c.volume / maxVolume) * volumeHeight;
      final barRect = Rect.fromLTWH(
        xCenter - (candleWidth * 0.35),
        size.height - barH,
        max(1.8, candleWidth * 0.7),
        barH,
      );
      canvas.drawRect(barRect, barPaint);
    }

    // Crosshair on hover
    if (hoverIndex != null && hoverIndex! < candles.length) {
      final x = hoverIndex! * candleWidth + (candleWidth / 2);
      final crossHairPaint = Paint()
        ..color = AppTheme.gold.withOpacity(0.8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), crossHairPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FinancialChartPainter oldDelegate) {
    return true;
  }
}
