enum MeterType {
  happiness,
  instability,
  safety,
  productivity,
  trust,
  underground,
  migration,
  corruption,
}

class MeterDef {
  final MeterType type;
  final String label;
  final String hint;

  const MeterDef(this.type, this.label, this.hint);
}

const List<MeterDef> kMeterDefs = [
  MeterDef(MeterType.happiness, 'Happiness', 'General satisfaction and morale.'),
  MeterDef(MeterType.instability, 'Instability', 'Crime, disorder, and volatility.'),
  MeterDef(MeterType.safety, 'Safety', 'How safe daily life feels.'),
  MeterDef(MeterType.productivity, 'Productivity', 'Economic output and work capacity.'),
  MeterDef(MeterType.trust, 'Trust', 'Confidence in institutions and rules.'),
  MeterDef(MeterType.underground, 'Underground', 'Black-market and covert activity.'),
  MeterDef(MeterType.migration, 'Pressure', 'Movement and displacement pressure.'),
  MeterDef(MeterType.corruption, 'Corruption', 'Leakage, bribery, and internal decay.'),
];
