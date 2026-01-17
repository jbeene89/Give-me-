/// Example usage of the Offer Engine
/// Demonstrates integration with game loop, offer handling, and effect application

import 'offer_exports.dart';

void main() {
  print('=== Offer Engine Examples ===\n');

  exampleBasicUsage();
  print('\n---\n');

  exampleCrisisOffers();
  print('\n---\n');

  exampleStreakOffers();
  print('\n---\n');

  examplePurchaseLimits();
  print('\n---\n');

  examplePerformanceTracking();
  print('\n---\n');

  exampleEffectApplication();
}

/// Example 1: Basic usage in game loop
void exampleBasicUsage() {
  print('Example 1: Basic Usage\n');

  final engine = OfferEngine(seed: 42);

  // Simulate game turns
  for (int turn = 1; turn <= 20; turn++) {
    final meterValues = {
      'stability': 0.45 + (turn * 0.01), // Gradually improving
      'capacity': 0.50,
      'reserves': 0.50,
      'clarity': 0.50,
      'morale': 0.50,
      'efficiency': 0.50,
    };

    final result = engine.checkForOffers(turn, meterValues);

    if (result.hasOffers) {
      print('Turn $turn: Offers available!');
      for (final offer in result.availableOffers) {
        print('  - ${offer.name} (${offer.priceTier})');
        print('    ${offer.benefitText}');
      }
    }
  }
}

/// Example 2: Crisis offers trigger
void exampleCrisisOffers() {
  print('Example 2: Crisis Offers\n');

  final engine = OfferEngine(seed: 100);

  // Simulate crisis situation
  final crisisMeterValues = {
    'stability': 0.28, // Below 30% threshold
    'capacity': 0.50,
    'reserves': 0.18, // Below 20% threshold
    'clarity': 0.32, // Below 35% threshold
    'morale': 0.50,
    'efficiency': 0.50,
  };

  print('Crisis state: stability=28%, reserves=18%, clarity=32%\n');

  final result = engine.checkForOffers(15, crisisMeterValues);

  if (result.hasOffers) {
    print('Crisis offers triggered:');
    for (final offer in result.availableOffers) {
      print('\n${offer.name} (${offer.priceTier})');
      print('  Description: ${offer.description}');
      print('  Benefit: ${offer.benefitText}');
      print('  Type: ${offer.offerType}');
      print('  Effects:');
      for (final effect in offer.effects) {
        print('    - $effect');
      }
    }
  } else {
    print('No offers (reason: ${result.reason})');
  }
}

/// Example 3: Streak offers (rewards for good play)
void exampleStreakOffers() {
  print('Example 3: Streak Offers\n');

  final engine = OfferEngine(seed: 200);

  // Simulate 12 turns of good performance
  print('Simulating 12 turns of good performance...\n');

  for (int turn = 1; turn <= 12; turn++) {
    final goodMeterValues = {
      'stability': 0.70,
      'capacity': 0.65,
      'reserves': 0.60,
      'clarity': 0.60,
      'morale': 0.65,
      'efficiency': 0.60,
    };

    final result = engine.checkForOffers(turn, goodMeterValues);

    if (result.hasOffers && result.availableOffers.isNotEmpty) {
      final streakOffers = result.availableOffers
          .where((o) => o.triggerCondition == TriggerCondition.streak);

      if (streakOffers.isNotEmpty) {
        print('Turn $turn: Streak offer available!');
        print('  Current streak: ${engine.getCurrentStreak()} turns');
        for (final offer in streakOffers) {
          print('  - ${offer.name}');
          print('    ${offer.description}');
          print('    Reward for ${offer.streakRequired} consecutive good turns!');
        }
      }
    }
  }

  print('\nFinal streak: ${engine.getCurrentStreak()} turns');
  print('Performance rating: ${(engine.getPerformanceRating() * 100).toStringAsFixed(0)}%');
}

/// Example 4: Purchase limits
void examplePurchaseLimits() {
  print('Example 4: Purchase Limits\n');

  final engine = OfferEngine(seed: 300);

  final crisisMeterValues = {
    'stability': 0.25,
    'capacity': 0.50,
    'reserves': 0.20,
    'clarity': 0.50,
    'morale': 0.50,
    'efficiency': 0.50,
  };

  // Emergency veto has limit of 3
  print('Emergency Override has a purchase limit of 3\n');

  for (int i = 1; i <= 4; i++) {
    final offerId = 'emergency_veto';

    if (engine.hasReachedPurchaseLimit(offerId)) {
      print('Attempt $i: ✗ Cannot purchase (limit reached)');
      break;
    }

    engine.recordPurchase(offerId);
    print('Attempt $i: ✓ Purchased (${engine.getPurchaseCount(offerId)}/3)');
  }

  print('\nThis prevents unlimited spending on powerful items.');
  print('Forces strategic choice about when to use limited resources.');
}

/// Example 5: Performance tracking
void examplePerformanceTracking() {
  print('Example 5: Performance Tracking\n');

  final engine = OfferEngine(seed: 400);

  print('Simulating mixed performance:\n');

  // Good turns
  for (int i = 1; i <= 5; i++) {
    engine.checkForOffers(i, {
      'stability': 0.70,
      'capacity': 0.65,
      'reserves': 0.60,
      'clarity': 0.60,
      'morale': 0.65,
      'efficiency': 0.60,
    });
    print('Turn $i: Good (streak: ${engine.getCurrentStreak()})');
  }

  // Bad turn (breaks streak)
  engine.checkForOffers(6, {
    'stability': 0.30,
    'capacity': 0.40,
    'reserves': 0.35,
    'clarity': 0.40,
    'morale': 0.35,
    'efficiency': 0.40,
  });
  print('Turn 6: Bad (streak: ${engine.getCurrentStreak()}) - RESET!');

  // More good turns
  for (int i = 7; i <= 12; i++) {
    engine.checkForOffers(i, {
      'stability': 0.70,
      'capacity': 0.65,
      'reserves': 0.60,
      'clarity': 0.60,
      'morale': 0.65,
      'efficiency': 0.60,
    });
    print('Turn $i: Good (streak: ${engine.getCurrentStreak()})');
  }

  print('\nPerformance rating: ${(engine.getPerformanceRating() * 100).toStringAsFixed(0)}%');
  print('Current streak: ${engine.getCurrentStreak()} turns');
}

/// Example 6: Effect application (pseudo-code)
void exampleEffectApplication() {
  print('Example 6: Effect Application\n');

  print('''
// When player purchases an offer:

void handlePurchase(Offer offer) {
  // Record purchase in engine
  offerEngine.recordPurchase(offer.id);

  // Apply each effect
  for (final effect in offer.effects) {
    switch (effect.type) {
      case OfferEffectType.meterBoost:
        // Instant meter increase
        final meter = gameState.getMeter(effect.target!);
        meter.value = (meter.value + effect.magnitude).clamp(0.0, 1.0);
        print('✓ Boosted \${effect.target} by \${effect.magnitude}');
        break;

      case OfferEffectType.resourceGrant:
        // Instant resource grant
        final current = gameState.getResource(effect.target!);
        gameState.setResource(effect.target!, current + effect.magnitude.toInt());
        print('✓ Granted \${effect.magnitude} \${effect.target}');
        break;

      case OfferEffectType.noiseReduction:
        // Temporary effect with expiry
        activeNoiseReduction = effect.magnitude;
        noiseReductionExpiry = currentTurn + effect.duration;
        print('✓ Noise reduced by \${effect.magnitude * 100}% for \${effect.duration} turns');
        break;

      case OfferEffectType.forecastExtension:
        // Show future turns
        forecastTurns = effect.magnitude.toInt();
        forecastExpiry = currentTurn + effect.duration;
        print('✓ Can see \${forecastTurns} turns ahead for \${effect.duration} turns');
        break;

      case OfferEffectType.collapseVeto:
        // Give player veto token
        vetoTokens++;
        print('✓ Gained emergency veto token (total: \$vetoTokens)');
        break;

      case OfferEffectType.revealBlindSpots:
        // Show hidden meters
        blindSpotsRevealed = true;
        blindSpotsExpiry = currentTurn + effect.duration;
        print('✓ All meters revealed for \${effect.duration} turns');
        break;

      case OfferEffectType.permanentModifier:
        // Permanent game modifier
        if (effect.target == 'decay') {
          decayMultiplier *= effect.magnitude; // Permanent!
          print('✓ Decay rate permanently reduced');
        }
        break;

      case OfferEffectType.actionCostReduction:
        // Permanent cost reduction
        actionCostMultiplier *= (1.0 - effect.magnitude);
        print('✓ Action costs permanently reduced by \${effect.magnitude * 100}%');
        break;
    }
  }
}

// When player declines:

void handleDecline(Offer offer) {
  offerEngine.recordDecline(offer.id);
  // No penalty! Just triggers cooldown so same offer doesn't
  // immediately reappear next turn
}

// Use active effects in game loop:

void applyFogMechanics() {
  var noise = baseFogNoise;

  // Apply noise reduction if active
  if (currentTurn < noiseReductionExpiry) {
    noise *= (1.0 - activeNoiseReduction);
  }

  return noise;
}

bool shouldHideMeter(String meterId) {
  // If blind spots revealed, don't hide
  if (currentTurn < blindSpotsExpiry) {
    return false;
  }

  // Normal fog logic
  return fogMechanics.isMeterHidden(meterId, clarity);
}

void onCollapseEvent(Event event) {
  // Check if player has veto token
  if (vetoTokens > 0) {
    showDialog('Use Emergency Veto?', [
      'Yes' -> {
        vetoTokens--;
        print('Collapse prevented!');
        return; // Event cancelled
      },
      'No' -> {},
    ]);
  }

  // Event happens normally
  triggerEvent(event);
}
''');
}

/// Example 7: Integration pattern
void exampleIntegrationPattern() {
  print('Example 7: Integration Pattern\n');

  print('''
class GameManager {
  late final OfferEngine offerEngine;

  Future<void> initialize() async {
    offerEngine = OfferEngine(seed: gameState.seed);
  }

  Future<void> onTurnEnd() async {
    currentTurn++;

    // Collect meter values
    final meters = {
      'stability': gameState.getMeter('stability').value,
      'capacity': gameState.getMeter('capacity').value,
      'reserves': gameState.getMeter('reserves').value,
      'clarity': gameState.getMeter('clarity').value,
      'morale': gameState.getMeter('morale').value,
      'efficiency': gameState.getMeter('efficiency').value,
    };

    // Check for offers
    final result = offerEngine.checkForOffers(currentTurn, meters);

    if (result.hasOffers) {
      // Show offer dialog
      final choice = await showOfferDialog(result.availableOffers);

      if (choice.accepted) {
        handlePurchase(choice.offer);
      } else {
        handleDecline(choice.offer);
      }
    }
  }

  Future<void> handlePurchase(Offer offer) async {
    // Later: Trigger IAP here
    // final success = await initiateIAP(offer.priceTier);
    // if (!success) return;

    // For now, just apply effects
    offerEngine.recordPurchase(offer.id);
    applyOfferEffects(offer);
    showNotification('\${offer.name} activated!');
  }

  void handleDecline(Offer offer) {
    offerEngine.recordDecline(offer.id);
    // No penalty!
  }
}
''');
}

/// Example 8: Ethical safeguards
void exampleEthicalSafeguards() {
  print('Example 8: Ethical Safeguards\n');

  print('''
The Offer Engine has multiple ethical safeguards:

1. **Global Cooldown** (3 turns)
   - Maximum 1 offer per 3 turns
   - Prevents offer spam
   - Player can focus on game

2. **Per-Offer Cooldowns** (8-15 turns)
   - Same offer doesn't keep appearing
   - Time to think and play
   - No pressure

3. **Purchase Limits**
   - Veto: Max 3 per game
   - Advisors: Max 2 per game
   - Upgrades: Max 1 per game
   - Prevents whale hunting

4. **No Declining Penalty**
   - Free to say no
   - Just triggers cooldown
   - No game consequences

5. **Streak Rewards**
   - Offers during GOOD times
   - Reward skill, not failure
   - Premium upgrades earned

6. **Transparent Effects**
   - Clear descriptions
   - Exact magnitudes shown
   - Duration specified
   - No hidden costs

7. **Game Completability**
   - All content accessible
   - No pay walls
   - Skill > spending
   - Offers are helpers, not requirements

Expected frequency: ~1 offer per 5-10 turns
This is gentle, not aggressive.
''');
}
