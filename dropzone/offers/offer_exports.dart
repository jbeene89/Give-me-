/// Public API exports for Offer Engine
/// Import this file to use the monetization offer system
library offers;

// Main engine
export 'offer_engine.dart' show OfferEngine, OfferCheckResult, OfferState, PerformanceTracker;

// Models
export 'models/offer.dart' show Offer;
export 'models/offer_types.dart' show
    OfferType,
    TriggerCondition,
    PriceTier,
    OfferEffect,
    OfferEffectType;

// Catalog
export 'offer_catalog.dart' show OfferCatalog;
