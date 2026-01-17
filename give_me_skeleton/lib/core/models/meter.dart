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
  MeterDef(MeterType.happiness, 'Happiness', 'Satisfaction across districts.'),
  MeterDef(MeterType.instability, 'Instability', 'Disorder spreading through systems.'),
  MeterDef(MeterType.safety, 'Safety', 'Security felt in daily routines.'),
  MeterDef(MeterType.productivity, 'Productivity', 'Output from economic districts.'),
  MeterDef(MeterType.trust, 'Trust', 'Faith in the system and its allocator.'),
  MeterDef(MeterType.underground, 'Underground', 'Shadow economy across zones.'),
  MeterDef(MeterType.migration, 'Pressure', 'Population movement between districts.'),
  MeterDef(MeterType.corruption, 'Corruption', 'System decay from within.'),
];
