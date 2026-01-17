# Offer Engine - Give (Me)

## Overview

The Offer Engine provides ethical, game-state-driven monetization without exploitative patterns. It decides **WHEN** to show offers and **WHAT** they contain based on:
- **Crisis situations** (player needs help understanding/controlling chaos)
- **Good performance** (rewarding skill, not exploiting failure)
- **Random opportunities** (surprise bonuses, not FOMO)

**This module contains NO actual in-app purchases** - it's pure logic for offer generation. IAP integration happens later in the UI layer.

## Design Philosophy

### What We Sell
- **Certainty**: Information (forecasts, clarity, audits)
- **Control**: Tools to manage chaos (vetoes, stability)
- **Efficiency**: Long-term investments (advisors, upgrades)

### What We DON'T Sell
- **Time pressure**: No ultra-short expiry timers
- **Pay-to-win**: Game is completable without purchases
- **Desperation**: Offers appear during good times too
- **Infinite scaling**: Purchase limits prevent whale hunting

## Offer Types (10 Total)

### Information Offers (3)
These help players understand the game better:

1. **Strategic Forecast** (Medium)
   - See 2 turns ahead for 5 turns
   - Crisis trigger: clarity < 40%
   - *Sells understanding, not power*

2. **Enhanced Monitoring** (Medium)
   - Reduce fog noise by 70% for 8 turns
   - Crisis trigger: clarity < 35%
   - *Cuts through information chaos*

3. **Comprehensive Audit** (Small)
   - Reveals blind spots for 6 turns
   - Crisis trigger: clarity < 30%
   - *Transparency over confusion*

### Stability Offers (3)
Emergency help without making game impossible:

4. **Emergency Override** (Large)
   - Prevent next collapse event (one-time)
   - Crisis trigger: stability < 30% OR reserves < 25%
   - Purchase limit: 3 per game
   - *Safety net, not crutch*

5. **Emergency Reserves** (Medium)
   - +25% reserves, +50 budget (instant)
   - Crisis trigger: reserves < 20%
   - *Breathing room during crisis*

6. **Coordination Support** (Medium)
   - Reduce decay 40% for 6 turns
   - Crisis trigger: stability < 35%
   - *Slow the chaos temporarily*

### Efficiency Offers (2)
Long-term permanent upgrades:

7. **Expert Advisor** (Premium)
   - Permanent: -10% action costs, +5% efficiency
   - Streak trigger: 8+ good turns, stability > 60%
   - Purchase limit: 2 per game
   - *Reward for skill, not failure*

8. **System Modernization** (Premium)
   - Permanent: -8% decay rate
   - Streak trigger: 10+ good turns, stability > 65%
   - Purchase limit: 1 per game
   - *Ultimate long-term investment*

### Random/Bonus Offers (2)
Surprise opportunities:

9. **Community Initiative** (Small)
   - +20% morale, +10% clarity (instant)
   - Random: 15% chance per turn
   - *Pleasant surprise, not FOMO*

10. **Workforce Initiative** (Medium)
    - +15% capacity, +20 influence (instant)
    - Random: 10% chance per turn
    - *Bonus opportunity*

## Architecture

### Core Components

1. **OfferEngine** (`offer_engine.dart`)
   - Checks for eligible offers each turn
   - Tracks cooldowns and purchase limits
   - Records performance for streak detection
   - Manages offer state

2. **Offer Models** (`models/`)
   - `Offer`: Complete offer definition
   - `OfferEffect`: What the offer does
   - `OfferType`, `TriggerCondition`, `PriceTier`: Enums

3. **OfferCatalog** (`offer_catalog.dart`)
   - All 10 offers defined
   - Filtering by type/trigger
   - Static catalog

4. **PerformanceTracker**
   - Tracks last 15 turns
   - Calculates streak count
   - Determines if player is doing well

## Integration Guide

### Step 1: Initialize OfferEngine

```dart
import 'package:give_me/dropzone/offers/offer_exports.dart';

class GameManager {
  late final OfferEngine _offerEngine;

  Future<void> initialize() async {
    _offerEngine = OfferEngine(seed: 12345); // Optional seed for testing
  }
}
```

### Step 2: Check for Offers Each Turn

```dart
class TurnEngine {
  final OfferEngine _offerEngine;

  Future<void> advanceTurn() async {
    currentTurn++;

    // ... normal turn logic ...

    // Check for offers
    final meterValues = {
      'stability': gameState.getMeter('stability').value,
      'capacity': gameState.getMeter('capacity').value,
      'reserves': gameState.getMeter('reserves').value,
      'clarity': gameState.getMeter('clarity').value,
      'morale': gameState.getMeter('morale').value,
      'efficiency': gameState.getMeter('efficiency').value,
    };

    final result = _offerEngine.checkForOffers(currentTurn, meterValues);

    if (result.hasOffers) {
      // Show offers to player
      _showOfferDialog(result.availableOffers);
    }
  }
}
```

### Step 3: Display Offers (UI Layer - Not Implemented Yet)

```dart
void _showOfferDialog(List<Offer> offers) {
  showDialog(
    context: context,
    builder: (context) => OfferDialog(
      offers: offers,
      onPurchase: (offer) => _handlePurchase(offer),
      onDecline: (offer) => _handleDecline(offer),
    ),
  );
}
```

### Step 4: Handle Purchase/Decline

```dart
Future<void> _handlePurchase(Offer offer) async {
  // Later: Trigger IAP flow here
  // For now, just record the purchase

  _offerEngine.recordPurchase(offer.id);

  // Apply effects
  _applyOfferEffects(offer);

  showNotification('${offer.name} activated!');
}

void _handleDecline(Offer offer) {
  _offerEngine.recordDecline(offer.id);
  // No penalty for declining - important!
}
```

### Step 5: Apply Offer Effects

```dart
void _applyOfferEffects(Offer offer) {
  for (final effect in offer.effects) {
    switch (effect.type) {
      case OfferEffectType.meterBoost:
        final meter = gameState.getMeter(effect.target!);
        meter.value = (meter.value + effect.magnitude).clamp(0.0, 1.0);
        break;

      case OfferEffectType.resourceGrant:
        final current = gameState.getResource(effect.target!);
        gameState.setResource(effect.target!, current + effect.magnitude.toInt());
        break;

      case OfferEffectType.noiseReduction:
        // Store active effect
        _activeNoiseReduction = effect.magnitude;
        _noiseReductionExpiry = currentTurn + effect.duration;
        break;

      case OfferEffectType.forecastExtension:
        _forecastTurns = effect.magnitude.toInt();
        _forecastExpiry = currentTurn + effect.duration;
        break;

      case OfferEffectType.collapseVeto:
        _vetoTokens++;
        break;

      case OfferEffectType.revealBlindSpots:
        _blindSpotsRevealed = true;
        _blindSpotsExpiry = currentTurn + effect.duration;
        break;

      case OfferEffectType.permanentModifier:
        if (effect.target == 'decay') {
          _decayMultiplier *= effect.magnitude; // Permanent
        }
        break;

      case OfferEffectType.actionCostReduction:
        _actionCostMultiplier *= (1.0 - effect.magnitude); // Permanent
        break;
    }
  }
}
```

### Step 6: Use Active Effects

```dart
// In TurnEngine or wherever effects are needed

// Fog mechanics with noise reduction
double getPerceivedMeterValue(String meterId, double actualValue) {
  var noise = fogMechanics.calculateNoise(clarity);

  // Apply active noise reduction from offer
  if (_activeNoiseReduction > 0 && currentTurn < _noiseReductionExpiry) {
    noise *= (1.0 - _activeNoiseReduction);
  }

  return actualValue + noise;
}

// Decay with permanent modifier
void applyDecay(Meter meter) {
  var decay = meter.baseDecayRate * activeModifiers.decayRateMultiplier;

  // Apply permanent offer modifier
  decay *= _decayMultiplier;

  meter.value -= decay;
}

// Action costs with reduction
int getActionCost(Action action) {
  var cost = action.baseCost * activeModifiers.actionCostMultiplier;

  // Apply permanent offer modifier
  cost *= _actionCostMultiplier;

  return cost.round();
}

// Blind spots reveal
bool isMeterHidden(String meterId) {
  // If reveal is active, don't hide
  if (_blindSpotsRevealed && currentTurn < _blindSpotsExpiry) {
    return false;
  }

  return fogMechanics.isMeterHidden(meterId, clarity);
}

// Collapse veto
void onCollapseEvent(GameEvent event) {
  if (_vetoTokens > 0) {
    // Ask player if they want to use veto
    if (await confirmVeto()) {
      _vetoTokens--;
      // Cancel event
      return;
    }
  }

  // Event happens
  triggerEvent(event);
}
```

## Future IAP Integration

### When IAP is Ready

1. **Add IAP Package**
   ```yaml
   dependencies:
     in_app_purchase: ^3.1.0
   ```

2. **Map Price Tiers to Products**
   ```dart
   const priceTierToProductId = {
     PriceTier.small: 'com.giveme.offer.small',
     PriceTier.medium: 'com.giveme.offer.medium',
     PriceTier.large: 'com.giveme.offer.large',
     PriceTier.premium: 'com.giveme.offer.premium',
   };
   ```

3. **Update Purchase Handler**
   ```dart
   Future<void> _handlePurchase(Offer offer) async {
     final productId = priceTierToProductId[offer.priceTier];

     // Trigger IAP
     final purchaseParam = PurchaseParam(
       productDetails: await getProductDetails(productId),
     );

     final success = await InAppPurchase.instance.buyConsumable(
       purchaseParam: purchaseParam,
     );

     if (success) {
       _offerEngine.recordPurchase(offer.id);
       _applyOfferEffects(offer);
     }
   }
   ```

4. **Verify Purchases**
   - Use receipt verification service
   - Never apply effects without verified purchase
   - Store purchases server-side if possible

5. **Restore Purchases**
   ```dart
   Future<void> restorePurchases() async {
     final purchases = await InAppPurchase.instance.restorePurchases();

     for (final purchase in purchases) {
       // Restore permanent purchases (advisors, upgrades)
       if (isPermanentOffer(purchase.productID)) {
         _offerEngine.recordPurchase(offerIdFromProduct(purchase.productID));
       }
     }
   }
   ```

## UI Integration Points

### Offer Dialog (To Be Implemented)

```dart
class OfferDialog extends StatelessWidget {
  final List<Offer> offers;
  final Function(Offer) onPurchase;
  final Function(Offer) onDecline;

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Opportunities Available'),
      content: Column(
        children: offers.map((offer) => OfferCard(
          offer: offer,
          onAccept: () => onPurchase(offer),
          onDecline: () => onDecline(offer),
        )).toList(),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final Offer offer;

  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(offer.name, style: Theme.of(context).textTheme.headline6),
          Text(offer.description),
          Text(offer.benefitText, style: TextStyle(color: Colors.blue)),

          // Show effects
          ...offer.effects.map((e) => Text('• ${_formatEffect(e)}')),

          // Price (placeholder for now)
          Text(_formatPrice(offer.priceTier)),

          // Buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: onAccept,
                child: Text('Accept'),
              ),
              TextButton(
                onPressed: onDecline,
                child: Text('Not Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(PriceTier tier) {
    // Placeholder - will be real prices from IAP later
    switch (tier) {
      case PriceTier.small:
        return '\$0.99';
      case PriceTier.medium:
        return '\$2.99';
      case PriceTier.large:
        return '\$4.99';
      case PriceTier.premium:
        return '\$9.99';
    }
  }
}
```

### Offer History/Shop (Optional)

```dart
class OfferShop extends StatelessWidget {
  // Show all offers, grayed out if on cooldown/limit reached
  // Player can see what's available and plan ahead
  // NO "limited time only" pressure
}
```

## Ethical Guidelines

### DO:
- Trigger offers during good times (streak rewards)
- Show clear cooldowns (transparency)
- Allow declining without penalty
- Offer information/tools, not just power
- Set purchase limits on powerful items
- Let game be completable without purchases

### DON'T:
- Create impossible situations without purchases
- Use ultra-short timers (< 1 hour)
- Hide costs or use dark patterns
- Exploit player desperation
- Make game unfun without purchases
- Target vulnerable players (whales)

## Trigger Frequency

Expected offer frequency with default settings:
- **Crisis offers**: 10-20% of turns when in crisis
- **Streak offers**: 5-10% of turns during good performance
- **Random offers**: 2-3% of turns
- **Global cooldown**: 3 turns between ANY offers

Average: **1 offer every 5-10 turns** (not overwhelming)

## Performance Tracking

The engine tracks last 15 turns to determine:
- **Streak count**: Consecutive good turns
- **Performance rating**: % of recent good turns
- **Good turn**: 60%+ of meters above 0.50

This rewards skill, not desperation.

## Testing

### Test Different Scenarios

```dart
test('Crisis offers trigger when appropriate', () {
  final engine = OfferEngine(seed: 42);

  final meterValues = {
    'stability': 0.25, // Crisis level
    'capacity': 0.50,
    'reserves': 0.50,
    'clarity': 0.50,
    'morale': 0.50,
    'efficiency': 0.50,
  };

  final result = engine.checkForOffers(10, meterValues);

  expect(result.hasOffers, true);
  // Should offer emergency/stability options
});

test('Streak offers require good performance', () {
  final engine = OfferEngine(seed: 42);

  // Simulate 10 turns of good performance
  for (int i = 1; i <= 10; i++) {
    engine.checkForOffers(i, {
      'stability': 0.70,
      'capacity': 0.65,
      'reserves': 0.60,
      'clarity': 0.60,
      'morale': 0.65,
      'efficiency': 0.60,
    });
  }

  final result = engine.checkForOffers(11, {
    'stability': 0.70,
    'capacity': 0.65,
    'reserves': 0.60,
    'clarity': 0.60,
    'morale': 0.65,
    'efficiency': 0.60,
  });

  // May or may not trigger (30% chance), but should be eligible
  expect(engine.getCurrentStreak(), greaterThanOrEqual(10));
});

test('Purchase limits enforced', () {
  final engine = OfferEngine(seed: 42);

  // Emergency veto has limit of 3
  engine.recordPurchase('emergency_veto');
  engine.recordPurchase('emergency_veto');
  engine.recordPurchase('emergency_veto');

  expect(engine.hasReachedPurchaseLimit('emergency_veto'), true);
});
```

## Serialization for Save/Load

```dart
// In save data:
{
  'offerStates': {
    'forecast_extension': {
      'lastOfferedTurn': 42,
      'purchaseCount': 0,
      'isActive': false,
    },
    'advisor_hire': {
      'lastOfferedTurn': 30,
      'purchaseCount': 1,
      'isActive': true,
    },
    // ... etc
  },
  'activeEffects': {
    // Store expiry times, tokens, etc.
    'vetoTokens': 2,
    'forecastTurns': 2,
    'forecastExpiry': 50,
  }
}
```

## Analytics (Future)

Track (with privacy):
- Offer shown → acceptance rate
- Price tier → conversion
- Crisis vs streak → conversion
- Which offers most popular
- No tracking of vulnerable behavior

## Summary

The Offer Engine provides ethical monetization by:
- **Respecting player agency** (no forced purchases)
- **Rewarding skill** (streak offers)
- **Providing tools** (information, not just power)
- **Setting boundaries** (cooldowns, limits)
- **Being transparent** (clear effects, no tricks)

It's a **layer on top** of the game, not a core dependency. The game works without it.
