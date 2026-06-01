import 'package:flutter/material.dart';

class Law {
  final String title;
  final String entity;
  final String description;
  final String details;
  final IconData icon;
  final Color color;

  const Law({
    required this.title,
    required this.entity,
    required this.description,
    required this.details,
    required this.icon,
    required this.color,
  });
}

final List<Law> _laws = [
  Law(
    title: 'Matrícula Mercantil',
    entity: 'Cámara de Comercio',
    description: 'Registro obligatorio para toda persona natural o jurídica que ejerza actividades mercantiles.',
    details: 'Según el Código de Comercio (Decreto 410 de 1971), toda empresa debe matricularse en la Cámara de Comercio de su jurisdicción antes de iniciar operaciones. La renovación se realiza anualmente entre enero y marzo. El incumplimiento genera sanciones y cierre del establecimiento.',
    icon: Icons.store,
    color: Color(0xff1565C0),
  ),
  Law(
    title: 'RUT - Registro Único Tributario',
    entity: 'DIAN',
    description: 'Mecanismo de identificación, ubicación y clasificación de los obligados a cumplir deberes formales ante la DIAN.',
    details: 'El RUT es obligatorio para todas las personas y entidades que realicen actividades económicas en Colombia (Ley 863 de 2003). Debe actualizarse cuando cambien los datos del contribuyente. Para emprendedores de alimentos, el régimen tributario (simplificado o común) define las obligaciones de facturación.',
    icon: Icons.assignment,
    color: Color(0xff1B5E20),
  ),
  Law(
    title: 'Registro Sanitario INVIMA',
    entity: 'INVIMA',
    description: 'Autorización sanitaria para la fabricación, procesamiento, preparación, envase, empaque, importación y comercialización de alimentos.',
    details: 'El Decreto 3075 de 1997 y la Resolución 2674 de 2013 regulan las condiciones sanitarias para la producción y comercialización de alimentos en Colombia. Los alimentos de alto riesgo requieren Registro Sanitario del INVIMA, mientras que los de bajo riesgo pueden acogerse al INVIMA Express o permiso de comercialización municipal.',
    icon: Icons.health_and_safety,
    color: Color(0xff880E4F),
  ),
  Law(
    title: 'Concepto Sanitario',
    entity: 'Secretaría de Salud',
    description: 'Documento expedido por la autoridad sanitaria local que certifica que el establecimiento cumple con las condiciones higiénico-sanitarias.',
    details: 'Obligatorio para establecimientos que produzcan, procesen o comercialicen alimentos (Resolución 2674 de 2013). Lo expide la Secretaría de Salud municipal o departamental previa visita de inspección. Debe renovarse periódicamente y mantenerse visible en el establecimiento.',
    icon: Icons.verified_user,
    color: Color(0xff004D40),
  ),
  Law(
    title: 'Uso de Suelo',
    entity: 'Alcaldía Municipal',
    description: 'Certificado que confirma que la actividad económica es compatible con el uso permitido en la zona donde opera el negocio.',
    details: 'Regulado por el Plan de Ordenamiento Territorial (POT) de cada municipio. Es requisito previo para obtener la licencia de funcionamiento. Sin este certificado, el establecimiento puede ser objeto de cierre por parte de las autoridades locales de planeación.',
    icon: Icons.location_city,
    color: Color(0xffE65100),
  ),
  Law(
    title: 'Régimen Simple de Tributación',
    entity: 'DIAN',
    description: 'Sistema voluntario y alternativo de determinación y pago del impuesto sobre la renta para pequeños empresarios.',
    details: 'Creado por la Ley 1943 de 2018 y ratificado por la Ley 2010 de 2019. Permite a personas naturales y jurídicas con ingresos brutos anuales inferiores a 100.000 UVT simplificar el cumplimiento tributario. Integra el impuesto de renta, ICA y el impuesto al consumo en un solo pago.',
    icon: Icons.account_balance,
    color: Color(0xff1A237E),
  ),
  Law(
    title: 'Facturación Electrónica',
    entity: 'DIAN',
    description: 'Sistema de facturación digital obligatorio para todos los sujetos obligados a expedir factura de venta.',
    details: 'Obligatoria según la Resolución 000042 de 2020 de la DIAN. El proceso de habilitación se realiza directamente en el portal de la DIAN o a través de un Proveedor Autorizado de Facturación Electrónica (PAFE). Los emprendedores formalizados deben expedir factura electrónica por cada operación de venta.',
    icon: Icons.receipt_long,
    color: Color(0xff006064),
  ),
  Law(
    title: 'Registro de Marca',
    entity: 'SIC - Superintendencia de Industria y Comercio',
    description: 'Protección legal del nombre, logo o signo distintivo del negocio a nivel nacional.',
    details: 'Regulado por la Decisión 486 de la Comunidad Andina y la Ley 446 de 1998. El registro otorga el derecho exclusivo de uso de la marca por 10 años renovables. Se realiza ante la SIC y protege al emprendedor de uso indebido de su marca por terceros.',
    icon: Icons.workspace_premium,
    color: Color(0xff4A148C),
  ),
  Law(
    title: 'Parafiscales y Seguridad Social',
    entity: 'UGPP / MinTrabajo',
    description: 'Aportes obligatorios al sistema de seguridad social y parafiscales para empleadores y trabajadores independientes.',
    details: 'Regulados por la Ley 100 de 1993 y el Decreto 1273 de 2018. Los emprendedores con empleados deben aportar a salud (12.5%), pensión (16%), ARL (según riesgo), ICBF (3%), SENA (2%) y Caja de Compensación (4%). Los independientes con ingresos superiores a 1 SMMLV también deben cotizar.',
    icon: Icons.people,
    color: Color(0xffBF360C),
  ),
];

class LawsTab extends StatefulWidget {
  const LawsTab({Key? key}) : super(key: key);

  @override
  State<LawsTab> createState() => _LawsTabState();
}

class _LawsTabState extends State<LawsTab> {
  String _searchQuery = '';

  List<Law> get _filteredLaws => _laws.where((law) {
        final q = _searchQuery.toLowerCase();
        return law.title.toLowerCase().contains(q) ||
            law.entity.toLowerCase().contains(q) ||
            law.description.toLowerCase().contains(q);
      }).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffE65100), Color(0xffFF8A65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.gavel, color: Colors.white, size: 26),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Normativas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('Leyes de formalización comercial',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar normativa...',
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xffE65100)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xffE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xffE65100), width: 2),
                ),
              ),
            ),
          ),

          // Lista
          Expanded(
            child: _filteredLaws.isEmpty
                ? const Center(
                    child: Text('No se encontraron normativas',
                        style: TextStyle(color: Color(0xff9E9E9E))))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredLaws.length,
                    itemBuilder: (context, index) =>
                        _buildLawCard(_filteredLaws[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawCard(Law law) {
    return GestureDetector(
      onTap: () => _showLawDetail(law),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: law.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(law.icon, color: law.color, size: 24),
          ),
          title: Text(
            law.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xff1a1a1a)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: law.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  law.entity,
                  style: TextStyle(
                      fontSize: 11,
                      color: law.color,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                law.description,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xff666666)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right,
              color: law.color.withOpacity(0.5)),
        ),
      ),
    );
  }

  void _showLawDetail(Law law) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header del detalle
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: law.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: law.color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: law.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(law.icon, color: law.color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            law.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: law.color),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: law.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              law.entity,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: law.color,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descripción',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      const SizedBox(height: 8),
                      Text(law.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff555555),
                              height: 1.5)),
                      const SizedBox(height: 16),
                      const Text('Marco legal y detalles',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      const SizedBox(height: 8),
                      Text(law.details,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff555555),
                              height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}