import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_signup/services/checklist_service.dart';

class ChecklistTab extends StatefulWidget {
  const ChecklistTab({Key? key}) : super(key: key);

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  // ── Estado ───────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _noChecklist = false;
  String? _errorMsg;

  List<dynamic> _items = [];
  Map<String, dynamic>? _resumen;
  String _etapaFiltro = 'TODAS';

  // ── Datos del formulario de inicialización ───────────────────────
  final _nombreCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  bool _initLoading = false;

  // ── Paleta de colores del proyecto ───────────────────────────────
  static const _green = Color(0xff2E7D32);
  static const _greenLight = Color(0xff66BB6A);
  static const _grey = Color(0xff9E9E9E);
  static const _dark = Color(0xff333333);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _tipoCtrl.dispose();
    _ciudadCtrl.dispose();
    super.dispose();
  }

  // ── Carga inicial ────────────────────────────────────────────────
  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _noChecklist = false;
    });

    final resumenResult = await ChecklistService.obtenerResumen();
    if (!mounted) return;

    if (!resumenResult['success']) {
      if (resumenResult['noChecklist'] == true ||
          (resumenResult['error'] ?? '').toString().contains('404')) {
        setState(() {
          _noChecklist = true;
          _isLoading = false;
        });
        return;
      }
    }

    final itemsResult = await ChecklistService.obtenerChecklist();
    if (!mounted) return;

    if (itemsResult['success']) {
      setState(() {
        _resumen = resumenResult['resumen'];
        _items = itemsResult['items'] ?? [];
        _isLoading = false;
      });
    } else if (itemsResult['noChecklist'] == true) {
      setState(() {
        _noChecklist = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg = itemsResult['error'];
        _isLoading = false;
      });
    }
  }

  // ── Inicializar checklist ────────────────────────────────────────
  Future<void> _inicializar() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _tipoCtrl.text.trim().isEmpty ||
        _ciudadCtrl.text.trim().isEmpty) {
      _showSnack('Completa todos los campos', isError: true);
      return;
    }

    setState(() => _initLoading = true);
    final result = await ChecklistService.inicializarChecklist(
      nombreNegocio: _nombreCtrl.text.trim(),
      tipoNegocio: _tipoCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _initLoading = false);

    if (result['success']) {
      _showSnack('¡Checklist creado exitosamente!');
      await _cargarDatos();
    } else {
      _showSnack(result['error'] ?? 'Error al inicializar', isError: true);
    }
  }

  // ── Marcar / desmarcar ítem ──────────────────────────────────────
  Future<void> _toggleItem(Map<String, dynamic> item) async {
    final itemId = item['itemId'] as String;
    final nuevoEstado = !(item['completado'] as bool? ?? false);

    // Actualización optimista
    setState(() {
      final idx = _items.indexWhere((e) => e['itemId'] == itemId);
      if (idx != -1) _items[idx]['completado'] = nuevoEstado;
    });

    final result = await ChecklistService.actualizarItem(
      itemId: itemId,
      completado: nuevoEstado,
    );

    if (!mounted) return;
    if (result['success']) {
      setState(() {
        if (_resumen != null) {
          _resumen!['porcentajeAvance'] = result['porcentajeAvance'];
          _resumen!['etapaActual'] = result['etapaActual'];
        }
      });
    } else {
      // Revertir si falla
      setState(() {
        final idx = _items.indexWhere((e) => e['itemId'] == itemId);
        if (idx != -1) _items[idx]['completado'] = !nuevoEstado;
      });
      _showSnack(result['error'] ?? 'Error al actualizar', isError: true);
    }
  }

  // ── Confirmar reset ──────────────────────────────────────────────
  Future<void> _confirmarReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reiniciar progreso'),
        content: const Text(
            'Se borrarán todos tus avances. Los datos de tu negocio se conservarán. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final result = await ChecklistService.resetearProgreso();
    if (!mounted) return;
    if (result['success']) {
      _showSnack('Progreso reiniciado');
      await _cargarDatos();
    } else {
      _showSnack(result['error'] ?? 'Error al reiniciar', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Items filtrados ──────────────────────────────────────────────
  List<dynamic> get _itemsFiltrados => _etapaFiltro == 'TODAS'
      ? _items
      : _items.where((e) => e['etapa'] == _etapaFiltro).toList();

  List<String> get _etapasDisponibles {
    final etapas = _items.map((e) => e['etapa'] as String).toSet().toList();
    etapas.sort();
    return etapas;
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _noChecklist
          ? _buildFormInicializar()
          : _errorMsg != null
          ? _buildError()
          : _buildChecklist(),
    );
  }

  // ── Error ────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: _grey),
            const SizedBox(height: 16),
            Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(color: _grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulario de inicialización ─────────────────────────────────
  Widget _buildFormInicializar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_green, _greenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.checklist_rtl, color: Colors.white, size: 36),
                SizedBox(height: 10),
                Text(
                  'Checklist de Formalización',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Registra tu negocio para comenzar tu ruta de formalización.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Datos de tu negocio',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _dark),
          ),
          const SizedBox(height: 16),
          _buildTextField(_nombreCtrl, 'Nombre del negocio', Icons.store),
          const SizedBox(height: 14),
          _buildTextField(_tipoCtrl, 'Tipo de negocio (ej. Restaurante)', Icons.category),
          const SizedBox(height: 14),
          _buildTextField(_ciudadCtrl, 'Ciudad', Icons.location_city),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _initLoading ? null : _inicializar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _initLoading
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Iniciar mi checklist',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Checklist principal ──────────────────────────────────────────
  Widget _buildChecklist() {
    final porcentaje = _resumen?['porcentajeAvance'] as int? ?? 0;
    final etapaActual = _resumen?['etapaActual'] as String? ?? '';
    final nombreNegocio = _resumen?['nombreNegocio'] as String? ?? '';

    final completados = _items.where((e) => e['completado'] == true).length;
    final total = _items.length;

    return RefreshIndicator(
      color: _green,
      onRefresh: _cargarDatos,
      child: CustomScrollView(
        slivers: [
          // ── Header con progreso ───────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_green, _greenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: _green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nombreNegocio,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: _confirmarReset,
                        icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                        tooltip: 'Reiniciar progreso',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completados de $total tramites completados',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: porcentaje / 100.0,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (etapaActual.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Etapa actual: ${ChecklistService.etapaLabel(etapaActual)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Filtros por etapa ─────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildChip('TODAS', 'Todas'),
                  ..._etapasDisponibles.map((e) => _buildChip(e, ChecklistService.etapaLabel(e))),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Lista de ítems ────────────────────────────────────────
          _itemsFiltrados.isEmpty
              ? const SliverFillRemaining(
            child: Center(
              child: Text('No hay ítems en esta etapa',
                  style: TextStyle(color: _grey)),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final item = _itemsFiltrados[i];
                return _buildItemCard(item);
              },
              childCount: _itemsFiltrados.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label) {
    final selected = _etapaFiltro == value;
    return GestureDetector(
      onTap: () => setState(() => _etapaFiltro = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _green : const Color(0xffE0E0E0)),
          boxShadow: selected
              ? [BoxShadow(color: _green.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _grey,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Tarjeta de ítem ──────────────────────────────────────────────
  Widget _buildItemCard(Map<String, dynamic> item) {
    final completado = item['completado'] as bool? ?? false;
    final omitido = item['omitido'] as bool? ?? false;
    final obligatorio = item['obligatorio'] as bool? ?? false;
    final etapa = item['etapa'] as String? ?? '';
    final etapaColor = Color(ChecklistService.etapaColor(etapa));
    final titulo = item['titulo'] as String? ?? '';
    final descripcion = item['descripcion'] as String? ?? '';
    final entidad = item['entidad'] as String? ?? '';
    final tiempoEstimado = item['tiempoEstimado'] as String? ?? '';
    final costoAproximado = item['costoAproximado'] as String? ?? '';
    final urlOficial = item['urlOficial'] as String? ?? '';
    final documentos = (item['documentosRequeridos'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: completado
            ? Border.all(color: _green.withOpacity(0.4), width: 1.5)
            : Border.all(color: const Color(0xffF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: () => _toggleItem(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completado ? _green : Colors.transparent,
                border: Border.all(
                  color: completado ? _green : const Color(0xffBDBDBD),
                  width: 2,
                ),
              ),
              child: completado
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          title: Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: completado ? _grey : _dark,
              decoration: completado ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: etapaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ChecklistService.etapaLabel(etapa),
                  style: TextStyle(color: etapaColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              if (obligatorio) ...[
                const SizedBox(width: 6),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Obligatorio',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Descripción
                  Text(descripcion,
                      style: const TextStyle(fontSize: 13, color: Color(0xff555555), height: 1.5)),
                  const SizedBox(height: 12),

                  // Metadatos
                  if (entidad.isNotEmpty) _buildMeta(Icons.business, 'Entidad', entidad),
                  if (tiempoEstimado.isNotEmpty)
                    _buildMeta(Icons.schedule, 'Tiempo estimado', tiempoEstimado),
                  if (costoAproximado.isNotEmpty)
                    _buildMeta(Icons.attach_money, 'Costo aprox.', costoAproximado),

                  // Documentos requeridos
                  if (documentos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Documentos requeridos:',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: _dark)),
                    const SizedBox(height: 4),
                    ...documentos.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(children: [
                        const Icon(Icons.fiber_manual_record, size: 8, color: _green),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(d,
                                style: const TextStyle(fontSize: 12, color: Color(0xff555555)))),
                      ]),
                    )),
                  ],

                  // URL oficial
                  if (urlOficial.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final raw = urlOficial.trim();
                          final withScheme =
                          raw.startsWith('http') ? raw : 'https://$raw';
                          final uri = Uri.parse(withScheme);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          } else {
                            if (context.mounted) {
                              _showSnack('No se pudo abrir el enlace', isError: true);
                            }
                          }
                        } catch (_) {
                          if (context.mounted) {
                            _showSnack('URL no válida', isError: true);
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new, size: 14, color: etapaColor),
                          const SizedBox(width: 6),
                          Text(
                            'Ver trámite oficial',
                            style: TextStyle(
                              fontSize: 12,
                              color: etapaColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Botón marcar
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleItem(item),
                      icon: Icon(
                        completado ? Icons.undo : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(completado ? 'Marcar como pendiente' : 'Marcar como completado'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: completado ? _grey : _green,
                        side: BorderSide(color: completado ? _grey : _green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _grey),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 12, color: _grey)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, color: _dark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}