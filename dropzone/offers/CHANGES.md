# Offer Engine - Changes and Assumptions

## What Was Added

### Core Features (Items 39-43)

1. **Offer System**
   - 10 total offers (6 required + 4 bonus)
   - 3 trigger types: crisis, streak, random
   - 4 offer types: information, stability, efficiency, emergency
   - 4 price tiers: small, medium, large, premium (placeholders)

2. **Crisis Triggers**
   - Triggered when meters fall below thresholds
   - Examples: stability < 30%, reserves < 20%, clarity < 35%
   - 6 crisis-triggered offers
   - Help players understand/control chaos

3. **Streak Triggers**
   - Triggered after 8-10 consecutive good turns
   - Good turn = 60%+ meters above 0.50
   - 2 streak offers (permanent upgrades)
   - Reward skill, not failure
   - Only 30% chance even when eligible (rare)

4. **Random Triggers**
   - 10-15% probability per turn (when off cooldown)
   - 2 random offers (surprise bonuses)
   - Not FOMO - just pleasant surprises

5. **Offer Engine**
   - Checks for eligible offers each turn
   - Enforces cooldowns (per-offer and global)
   - Enforces purchase limits
   - Tracks performance for streaks
   - Maximum 2 offers shown simultaneously

6. **Effects System**
   - 8 effect types defined
   - Instant, timed, and permanent effects
   - Meter boosts, resource grants, modifiers
   - Information effects (forecast, clarity, reveal)
   - Emergency effects (veto, stability)

7. **Performance Tracking**
   - Tracks last 15 turns
   - Calculates consecutive streak
   - Computes overall performance rating
   - Used for streak offer eligibility

8. **Ethical Safeguards**
   - Global cooldown: 3 turns between offers
   - Per-offer cooldowns: 8-15 turns
   - Purchase limits on powerful items
   - No punishment for declining
   - Game completable without purchases

### File Structure

```
dropzone/offers/
├── models/
│   ├── offer_types.dart       # Enums and OfferEffect class
│   └── offer.dart              # Complete Offer model
├── offer_catalog.dart          # All 10 offers defined
├── offer_engine.dart           # Main logic engine
├── offer_exports.dart          # Public API
├── README.md                   # Integration guide
└── CHANGES.md                  # This file
```

## Offers Implemented (10 Total)

### Information Offers (3)

**1. Strategic Forecast** (Medium - $2.99)
- Effect: See 2 turns ahead for 5 turns
- Trigger: Crisis (clarity < 40%)
- Cooldown: 10 turns
- Sells: Planning ability, not power

**2. Enhanced Monitoring** (Medium - $2.99)
- Effect: Reduce noise 70% for 8 turns
- Trigger: Crisis (clarity < 35%)
- Cooldown: 12 turns
- Sells: Clarity, not blind luck

**3. Comprehensive Audit** (Small - $0.99)
- Effect: Reveal blind spots for 6 turns
- Trigger: Crisis (clarity < 30%)
- Cooldown: 10 turns
- Sells: Transparency, not hidden traps

### Stability/Emergency Offers (3)

**4. Emergency Override** (Large - $4.99)
- Effect: Veto next collapse (one-time)
- Trigger: Crisis (stability < 30% OR reserves < 25%)
- Cooldown: 15 turns
- Limit: 3 per game
- Sells: Safety net, not pay-to-live

**5. Emergency Reserves** (Medium - $2.99)
- Effect: +25% reserves, +50 budget (instant)
- Trigger: Crisis (reserves < 20%)
- Cooldown: 8 turns
- Sells: Breathing room, not mandatory bailout

**6. Coordination Support** (Medium - $2.99)
- Effect: -40% decay for 6 turns
- Trigger: Crisis (stability < 35%)
- Cooldown: 10 turns
- Sells: Time to think, not permanent crutch

### Efficiency Offers (2)

**7. Expert Advisor** (Premium - $9.99)
- Effect: Permanent -10% action costs, +5% efficiency
- Trigger: Streak (8 good turns, stability > 60%)
- Limit: 2 per game
- Sells: Long-term investment, reward for skill

**8. System Modernization** (Premium - $9.99)
- Effect: Permanent -8% decay
- Trigger: Streak (10 good turns, stability > 65%)
- Limit: 1 per game
- Sells: Ultimate upgrade, earned not bought

### Random/Bonus Offers (2)

**9. Community Initiative** (Small - $0.99)
- Effect: +20% morale, +10% clarity (instant)
- Trigger: Random (15% chance)
- Cooldown: 12 turns
- Sells: Pleasant surprise, not FOMO

**10. Workforce Initiative** (Medium - $2.99)
- Effect: +15% capacity, +20 influence (instant)
- Trigger: Random (10% chance)
- Cooldown: 15 turns
- Sells: Bonus opportunity, not necessity

## Design Decisions & Rationale

### Why Crisis Triggers?

**Rationale:**
- Player genuinely needs help understanding complex system
- Offers provide tools (information, stability) not just power
- Crisis doesn't mean "about to lose" - just heightened difficulty
- Offers also appear during good times (streaks)

**Safeguards:**
- Cooldowns prevent spam during crisis
- Game is winnable without purchases
- Effects are temporary (except upgrades)
- Declining has no penalty

### Why Streak Triggers?

**Rationale:**
- Reward skilled play, not failure
- Show that purchases aren't just for struggling players
- Permanent upgrades feel earned
- Encourages mastery

**Safeguards:**
- Require sustained good performance (8-10 turns)
- Only 30% chance even when eligible (rare)
- High price tier (premium)
- Purchase limits (1-2 per game)

### Why Random Triggers?

**Rationale:**
- Add variety and surprise
- Not tied to crisis or success
- Feel like lucky opportunities

**Safeguards:**
- Low probability (10-15%)
- Cooldowns prevent spam
- Not time-limited (no FOMO)
- Optional bonuses, not necessities

### Why Global Cooldown?

**Rationale:**
- Prevent offer spam (max 1 offer per 3 turns)
- Gives player time to play without interruption
- Reduces pressure and annoyance

**Frequency:**
- With cooldowns, expect ~1 offer every 5-10 turns
- Not overwhelming
- Player can focus on game

### Why Purchase Limits?

**Rationale:**
- Prevent whale hunting (unlimited spending)
- Powerful items limited (veto: 3, advisor: 2, upgrade: 1)
- Creates actual scarcity, not artificial FOMO
- Forces strategic choice

**Effect:**
- Maximum spend per game: ~$50-60 if buying everything
- Can't just buy your way to victory infinitely
- Skill still matters

### Why No Time Pressure?

**Rationale:**
- No "expires in 10 minutes!" timers
- No "limited time offer!" FOMO
- Player can decline without feeling they missed out
- Respects player agency

**Implementation:**
- Offers are cooldown-based, not time-based
- Same offer can appear again later
- No punishment for waiting

### Why Transparency?

**Rationale:**
- Show exactly what offer does
- Show purchase counts and limits
- Show cooldowns
- No hidden costs

**UI Implications:**
- Clear effect descriptions
- "Purchased X/Y times" displayed
- "Available again in N turns" if on cooldown
- Real prices from IAP (when implemented)

## Assumptions Made

### Game State Assumptions

- **Meters exist:**
  - stability, capacity, reserves, clarity, morale, efficiency
  - Normalized 0.0-1.0
  - Accessible as map

- **Resources exist:**
  - budget and influence (minimum)
  - Integer values
  - Can be modified

- **Turn counter:**
  - Integer, monotonically increasing
  - Starts at 0 or 1

- **Performance measurable:**
  - Can determine if turn was "good" or "bad"
  - Based on meter values

### Integration Assumptions

- **TurnEngine integration:**
  - Called each turn to check for offers
  - Has access to current meter values
  - Can show/hide offers to player

- **Effect application:**
  - TurnEngine applies effects to game state
  - Tracks active effects and expiry
  - Enforces permanent modifiers

- **UI layer:**
  - Will display offers in dialog or screen
  - Will handle purchase/decline buttons
  - Will trigger IAP flow (future)

- **Persistence:**
  - Offer states saved/loaded with game
  - Purchase counts and cooldowns preserved
  - Active effects restored

### Monetization Assumptions

- **IAP not implemented yet:**
  - Price tiers are placeholders
  - No actual payment processing
  - Logic only

- **Future IAP integration:**
  - Will use in_app_purchase package
  - Products map to price tiers
  - Server-side verification recommended

- **Revenue expectations:**
  - ~5-10% conversion rate (industry standard)
  - Average spend ~$5-15 per paying user
  - Not designed for whales

## What Was Intentionally NOT Implemented

### Out of Scope

1. **Actual IAP Integration**
   - No in_app_purchase package
   - No product IDs
   - No payment processing
   - No receipt verification
   - Pure logic only

2. **UI Components**
   - No offer dialog widgets
   - No shop screen
   - No purchase confirmation
   - Integration examples only

3. **Time-Based Expiry**
   - No "expires in X minutes" timers
   - No real-time countdowns
   - Only turn-based cooldowns
   - No FOMO pressure

4. **Dynamic Pricing**
   - No A/B testing prices
   - No surge pricing
   - No personalized pricing
   - Fixed price tiers

5. **Social/Competitive Features**
   - No "your friend bought this"
   - No leaderboards showing spenders
   - No gift/sharing mechanisms
   - Single-player focus

6. **Consumable Spam**
   - No "buy 100 coins" packs
   - No soft currency exchange
   - No daily deals/subscriptions
   - Direct offers only

7. **Progression Gates**
   - No "pay to unlock level"
   - No "pay to speed up"
   - No artificial wait timers
   - Game fully playable

8. **Analytics Tracking**
   - No user behavior tracking
   - No whale identification
   - No targeting algorithms
   - Privacy-first design

9. **Gambling Mechanics**
   - No loot boxes
   - No gacha/randomized rewards
   - No "spin the wheel"
   - Deterministic offers

10. **Dark Patterns**
    - No hidden costs
    - No bait-and-switch
    - No misleading buttons
    - No pre-checked subscriptions

## Manipulative Patterns Avoided

See FINAL CHECK section below for detailed analysis.

## Effect Implementation Notes

### Instant Effects (duration: -1)
Apply immediately and permanently:
- Meter boosts: Add to meter, clamp to [0, 1]
- Resource grants: Add to resource value
- Example: Emergency Reserves

### Timed Effects (duration: N)
Apply for N turns, then expire:
- Store effect magnitude
- Store expiry turn (currentTurn + duration)
- Check expiry each turn
- Example: Noise reduction, forecast

### Permanent Effects (duration: 0)
Apply permanently, never expire:
- Modify multipliers permanently
- Store in game state modifiers
- Persist across saves
- Example: Advisors, upgrades

### Consumable Effects (special)
Used when triggered, then consumed:
- Store token count
- Decrement when used
- Player chooses when to use
- Example: Collapse veto

## Testing Strategy

### Unit Tests

```dart
test('Crisis offers trigger correctly', () { ... });
test('Streak offers require good performance', () { ... });
test('Random offers use probability', () { ... });
test('Cooldowns enforced', () { ... });
test('Purchase limits enforced', () { ... });
test('Global cooldown prevents spam', () { ... });
test('Performance tracking accurate', () { ... });
```

### Integration Tests

```dart
test('Offers integrate with TurnEngine', () { ... });
test('Effects apply to game state', () { ... });
test('Offer states persist across save/load', () { ... });
test('Multiple simultaneous offers handled', () { ... });
```

### Playtesting Focus

- Do offers feel fair and helpful?
- Is frequency too high/low?
- Are prices reasonable?
- Does declining feel okay?
- Can game be completed without purchases?
- Do streak offers feel rewarding?

## Balance Tuning

Expected conversion rates:
- **Crisis offers**: 10-20% acceptance (genuine need)
- **Streak offers**: 40-60% acceptance (reward feeling)
- **Random offers**: 5-15% acceptance (surprise factor)

Frequency tuning:
- Reduce global cooldown → more frequent offers
- Increase thresholds → fewer crisis triggers
- Adjust probabilities → more/fewer random offers

Effect tuning:
- Increase magnitude → more powerful
- Increase duration → longer lasting
- Adjust costs → change perceived value

## Future Enhancements (Not Implemented)

- Seasonal/event offers
- Bundle offers (multiple effects)
- First-time buyer bonus
- Referral rewards (non-manipulative)
- Restore purchases for permanent items
- Offer preview/history screen
- Analytics dashboard (privacy-respecting)
- A/B test pricing (ethical implementation)

## Dependencies

### Current

- None (pure Dart logic)

### Future (when IAP implemented)

- `in_app_purchase: ^3.1.0` (official Flutter IAP)
- Backend for receipt verification (recommended)
- Analytics service (optional, privacy-respecting)

## Ethical Framework

### Principles

1. **Respect player agency**
   - No forced purchases
   - Declining is consequence-free
   - Game completable without spending

2. **Transparency**
   - Clear effects and prices
   - No hidden costs
   - Obvious what you're buying

3. **Fairness**
   - Reward skill (streaks)
   - Help understanding (information)
   - No pay-to-win

4. **Boundaries**
   - Purchase limits
   - Cooldowns
   - No time pressure

5. **Privacy**
   - No targeting of vulnerable
   - No exploitation of desperation
   - No behavioral manipulation

### Red Lines (Never Cross)

- ❌ Making game unwinnable without purchases
- ❌ Targeting whales/vulnerable players
- ❌ Time pressure under 1 hour
- ❌ Dark patterns (hidden costs, etc.)
- ❌ Gambling mechanics (loot boxes)
- ❌ Pay-to-skip artificial timers
- ❌ Social pressure to spend
- ❌ Deceptive advertising

## Version

- **Version**: 1.0
- **Date**: 2026-01-17
- **Status**: Logic complete, IAP integration pending
- **Dependencies**: Event Engine, Scenario System, Persistence (for save/load)
- **Items Implemented**: 39-43 (monetization logic)
