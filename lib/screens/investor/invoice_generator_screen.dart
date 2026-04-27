import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/invoice_service.dart';
import '../../services/invoice_preview_service.dart';

class InvoiceGeneratorScreen extends StatefulWidget {
  const InvoiceGeneratorScreen({super.key});

  @override
  State<InvoiceGeneratorScreen> createState() => _InvoiceGeneratorScreenState();
}

class _InvoiceGeneratorScreenState extends State<InvoiceGeneratorScreen>
    with SingleTickerProviderStateMixin {
  // ── Brand colours ────────────────────────────────────────────────────────────
  static const _purple = Color(0xFF8259EF);
  static const _dark = Color(0xFF1A1033);
  static const _accent = Color(0xFFB39DDB);
  static const _green = Color(0xFF4ADE80);

  // ── State ────────────────────────────────────────────────────────────────────
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  final _selectedTypes = <String>{
    'land_rental',
    'item_purchase',
    'product_purchase',
  };

  InvoicePreviewData? _preview;
  bool _loadingPreview = false;
  bool _generatingPdf = false;
  String? _previewError;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadPreview();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _range,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _purple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A1A2E),
            secondary: _purple,
            onSecondary: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _purple),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _range = picked);
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    if (_selectedTypes.isEmpty) {
      setState(() => _preview = null);
      return;
    }
    setState(() {
      _loadingPreview = true;
      _previewError = null;
    });
    try {
      final data = await InvoicePreviewService.fetchPreview(
        from: _range.start,
        to: _range.end,
        types: _selectedTypes.toList(),
      );
      if (mounted) setState(() { _preview = data; _loadingPreview = false; });
    } catch (e) {
      if (mounted) setState(() { _previewError = e.toString(); _loadingPreview = false; });
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedTypes.isEmpty) {
      _showSnack('Select at least one activity type.', isError: true);
      return;
    }
    setState(() => _generatingPdf = true);
    try {
      final bytes = await InvoiceService.generateInvoice(
        from: _range.start,
        to: _range.end,
        types: _selectedTypes.toList(),
      );
      if (!mounted) return;
      // Open native share / print sheet
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFF87171) : _purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1033), Color(0xFF0D0A1F), Color(0xFF12083A)],
                ),
              ),
            ),
          ),

          // Ambient glow orb top-right
          Positioned(
            top: -60, right: -40,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _purple.withOpacity(0.18 + _pulseCtrl.value * 0.06),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          SafeArea(
            child: _generatingPdf ? _buildGeneratingOverlay() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('DATE RANGE'),
                const SizedBox(height: 8),
                _buildDateRangeCard(),
                const SizedBox(height: 24),
                _buildSectionLabel('ACTIVITY TYPES'),
                const SizedBox(height: 10),
                _buildTypeChips(),
                const SizedBox(height: 24),
                _buildSectionLabel('PREVIEW'),
                const SizedBox(height: 10),
                _buildPreviewCard(),
                const SizedBox(height: 32),
                _buildGenerateButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)]),
              boxShadow: [BoxShadow(color: const Color(0xFF2D6A4F).withOpacity(0.5), blurRadius: 12)],
            ),
            child: const Center(
              child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('INVOICE GENERATOR', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900,
                fontSize: 14, letterSpacing: 1.5,
              )),
              Text('Blockchain-verified PDF', style: TextStyle(
                color: _accent.withOpacity(0.7), fontSize: 11,
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(label, style: TextStyle(
      color: _accent.withOpacity(0.6),
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
    ));
  }

  // ── Date range card ───────────────────────────────────────────────────────────
  Widget _buildDateRangeCard() {
    return GestureDetector(
      onTap: _pickDateRange,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _purple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(child: _dateBox('FROM', _range.start)),
                Container(width: 1, height: 40, color: _purple.withOpacity(0.3)),
                Expanded(child: _dateBox('TO', _range.end)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_purple, Color(0xFF5B2BE8)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateBox(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _accent.withOpacity(0.6), fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(_fmtDate(date), style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
          )),
        ],
      ),
    );
  }

  // ── Type chips ────────────────────────────────────────────────────────────────
  Widget _buildTypeChips() {
    final chips = [
      {'key': 'land_rental', 'label': '🌿 Land Rentals', 'color': _green},
      {'key': 'item_purchase', 'label': '🎮 Asset Purchases', 'color': _accent},
      {'key': 'product_purchase', 'label': '🛍️ Products', 'color': const Color(0xFF60A5FA)},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips.map((chip) {
        final key = chip['key'] as String;
        final selected = _selectedTypes.contains(key);
        final color = chip['color'] as Color;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedTypes.remove(key);
              } else {
                _selectedTypes.add(key);
              }
            });
            _loadPreview();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 14, color: color)
                else
                  Icon(Icons.radio_button_unchecked_rounded, size: 14, color: Colors.white30),
                const SizedBox(width: 6),
                Text(chip['label'] as String, style: TextStyle(
                  color: selected ? color : Colors.white54,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 13,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Preview card ──────────────────────────────────────────────────────────────
  Widget _buildPreviewCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _purple.withOpacity(0.25)),
          ),
          child: _loadingPreview
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: _purple, strokeWidth: 2),
                    ),
                  ),
                )
              : _previewError != null
                  ? Row(children: [
                      const Icon(Icons.info_outline, color: Color(0xFFF87171), size: 18),
                      const SizedBox(width: 8),
                      const Text('Could not load preview', style: TextStyle(color: Color(0xFFF87171))),
                    ])
                  : _preview == null
                      ? Text('Select types to see a preview.',
                          style: TextStyle(color: Colors.white.withOpacity(0.4)))
                      : Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_outlined, color: _purple, size: 18),
                                const SizedBox(width: 8),
                                Text('SUMMARY', style: TextStyle(
                                  color: _accent.withOpacity(0.7),
                                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2,
                                )),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _statPill(_preview!.recordCount.toString(), 'Records', Icons.link_rounded, _purple),
                                const SizedBox(width: 12),
                                _statPill(
                                  '\$${_preview!.totalAmount.toStringAsFixed(2)}',
                                  'Total (USD)',
                                  Icons.attach_money_rounded,
                                  _green,
                                ),
                              ],
                            ),
                            if (_preview!.countByType.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ..._preview!.countByType.entries.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text(_typeLabel(e.key), style: TextStyle(
                                      color: Colors.white.withOpacity(0.5), fontSize: 11,
                                    )),
                                    const Spacer(),
                                    Text('${e.value} record${e.value != 1 ? 's' : ''}',
                                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _statPill(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 16,
                )),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'land_rental': return '🌿 Land Rentals';
      case 'item_purchase': return '🎮 Asset Purchases';
      case 'product_purchase': return '🛍️ Product Purchases';
      default: return type;
    }
  }

  // ── Generate button ───────────────────────────────────────────────────────────
  Widget _buildGenerateButton() {
    final canGenerate = _selectedTypes.isNotEmpty &&
        (_preview == null || _preview!.recordCount > 0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generatePdf : null,
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: Text(
          _preview != null && _preview!.recordCount == 0
              ? 'No Records in Range'
              : 'Generate PDF Invoice',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D6A4F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.06),
          disabledForegroundColor: Colors.white30,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Generating overlay ────────────────────────────────────────────────────────
  Widget _buildGeneratingOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)]),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF2D6A4F).withOpacity(0.3 + _pulseCtrl.value * 0.4),
                  blurRadius: 40, spreadRadius: 4,
                )],
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Generating your invoice...', style: TextStyle(
            color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Text('Fetching blockchain records', style: TextStyle(
            color: Colors.white.withOpacity(0.35), fontSize: 12,
          )),
        ],
      ),
    );
  }
}
