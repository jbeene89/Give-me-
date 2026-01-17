/// Public API exports for Event Engine
/// Import this file to use the Event Engine in TurnEngine
library event_engine;

// Main engine
export 'event_engine.dart' show EventEngine;

// Models
export 'models/event.dart' show GameEvent, EventTriggerType, ThresholdTrigger, CompoundTrigger;
export 'models/event_effect.dart' show EventEffect;
export 'models/event_log_entry.dart' show EventLogEntry;

// Catalog
export 'event_catalog.dart' show EventCatalog;

// Fog mechanics (if needed for custom integration)
export 'fog_mechanics.dart' show FogMechanics, DelayedEffectQueue;
