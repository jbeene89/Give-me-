# Endgame Analysis - Changes and Assumptions

## What Was Added

### Core Features (Items 48-50)

1. **Run Summary**
   - Turns survived
   - Scenario and difficulty names
   - End condition (optional)
   - Final meter values
   - Total events encountered

2. **Optimization Statements (3-5)**
   - Evidence-based conclusions about player priorities
   - Tradeoff detection (X over Y)
   - Focus area detection (emphasized/neglected X)
   - Trend pattern detection (built up X)
   - Confidence scoring (0.0-1.0)
   - Supporting evidence with thresholds

3. **Archetype Classification**
   - Six behavioral dimensions (0.0-1.0 scale)
   - Deterministic formulas
   - Evidence for each dimension
   - Generated label (e.g., "Proactive Authoritarian Administrator")
   - Neutral description of play style

4. **Evidence System**
   - Types: meter level, trend, pattern, comparative
   - Observations with numerical support
   - Thresholds for transparency
   - Timeframes where applicable

5. **Analysis Engine**
   - Combines meter history into insights
   - Generates complete EndgameReport
   - Selects best 3-5 optimization statements
   - Calculates archetype dimensions
   - 100% deterministic (same input = same output)

### File Structure

```
dropzone/endgame/
├── models/
│   ├── evidence.dart                # Evidence and types
│   ├── optimization_statement.dart  # Statements and templates
│   ├── archetype.dart              # Dimensions and classification
│   └── endgame_report.dart         # Complete report model
├── analyzers/
│   ├── meter_analyzer.dart         # Meter pattern analysis
│   ├── archetype_analyzer.dart     # Behavioral dimension calculation
│   └── optimization_analyzer.dart  # Tradeoff and focus detection
├── analysis_engine.dart            # Main orchestrator
├── endgame_exports.dart            # Public API
├── README.md                       # Integration guide
└── CHANGES.md                      # This file
```

## Design Decisions

### Optimization Statement Types

**1. Tradeoff Statements**
- Requires: Difference >= 0.20 between two meters
- Requires: Prioritized >= 0.60, Sacrificed <= 0.40
- Examples: "You prioritized X over Y", "You traded Y for X"
- Confidence: Based on gap size beyond threshold

**2. Focus Statements**
- High focus: Average >= 0.70
- Low focus: Average <= 0.30
- Examples: "You emphasized X", "You deprioritized X"
- Confidence: Based on distance from threshold

**3. Trend Statements**
- Requires: Trend > 0.05 and final value > 0.6
- Example: "You built up X over time"
- Confidence: Based on trend magnitude

### Archetype Dimensions

**Why These Six?**

1. **Proactivity** - Fundamental: do you prevent or react?
2. **Control** - Core tradeoff: order vs freedom
3. **Risk Tolerance** - Resource management style
4. **Information Seeking** - Decision-making style
5. **Stability Focus** - Strategic priority
6. **Aggression** - Growth tempo

These cover the main strategic axes without being too granular.

**Why 0.0-1.0 Scale?**
- Neutral midpoint (0.5)
- Both ends are valid strategies
- No "good" or "bad" ends
- Clear visualization (progress bars)

**Why Three Labels Per Dimension?**
- Low (<0.4), Neutral (0.4-0.6), High (>0.6)
- Avoids false precision
- Recognizes balanced play as valid

### Thresholds

All thresholds are explicit and documented:

**Tradeoff Detection:**
- Gap threshold: 0.20 (significant difference)
- High threshold: 0.60 (clearly prioritized)
- Low threshold: 0.40 (clearly sacrificed)

**Focus Detection:**
- Very high: 0.70 (strong emphasis)
- Very low: 0.30 (clear neglect)

**Trend Detection:**
- Significant trend: 0.05 (rising/falling)
- Stable: ±0.02 (minimal change)

**Archetype Calculation:**
- Dominant: > 0.6
- Recessive: < 0.4
- Balanced: 0.4-0.6

### Language Choices

**Neutral Pairs:**
- Reactive ←→ Proactive (both valid)
- Permissive ←→ Authoritarian (both strategies)
- Risk-Averse ←→ Risk-Tolerant (both reasonable)
- Intuition-Driven ←→ Information-Driven (both work)
- Efficiency-Focused ←→ Stability-Focused (both priorities)
- Conservative ←→ Aggressive (both tempos)

**Avoided Terms:**
- Good/bad, right/wrong
- Cruel, kind, selfish, generous
- Smart, dumb, foolish, wise
- Should/shouldn't, must/mustn't

**Template Verbs:**
- Prioritized, emphasized, invested (positive frame)
- Traded, sacrificed, maintained (neutral frame)
- Deprioritized, neglected (neutral, not negative)

## Assumptions Made

### Game Data Assumptions

- **Meter history available:**
  - Turn-by-turn values for all 6 meters
  - List<double> for each meter
  - At least 3 turns of data (for trend calculation)

- **Meters exist:**
  - stability, capacity, reserves, clarity, morale, efficiency
  - All normalized 0.0-1.0

- **Scenario/Difficulty metadata:**
  - Scenario ID or name
  - Difficulty ID or name
  - Available at game end

- **Event tracking:**
  - Total count of events
  - Optional: event log details

### Integration Assumptions

- **Called at game end:**
  - After final turn processed
  - With complete meter history
  - With end condition (if collapsed)

- **UI displays report:**
  - Can show multiple sections
  - Can render progress bars
  - Can display evidence lists

- **Optional persistence:**
  - Reports can be saved to file
  - JSON serialization available
  - Text export available

### Analysis Assumptions

- **Sufficient data:**
  - At least 5 turns for meaningful analysis
  - More turns = more reliable patterns
  - Trends need >= 3 data points

- **Meter independence:**
  - Can compare any two meters
  - No hidden dependencies assumed
  - Analysis is correlation, not causation

- **Player agency:**
  - Meter values reflect player choices
  - Not just random events
  - Patterns are meaningful

## What Was Intentionally NOT Implemented

### Out of Scope

1. **Prescriptive Advice**
   - No "you should have..." statements
   - No "try this next time" suggestions
   - No optimal strategy recommendations
   - Player discovers their own learnings

2. **Moral Judgment**
   - No "good" or "bad" labels
   - No personality psychology
   - No ethical evaluation
   - Pure behavioral description

3. **Comparative Analysis**
   - No "better than X% of players"
   - No leaderboards or rankings
   - No "optimal" benchmarks
   - Single-player focus

4. **Action Tracking**
   - No specific action history
   - No "you used X action Y times"
   - Meter patterns only
   - Keeps analysis simple

5. **Predictive Analysis**
   - No "you would have lasted N more turns if..."
   - No counterfactuals
   - No what-if scenarios
   - Descriptive only

6. **Personality Inference**
   - No "you are a control freak"
   - No "you're risk-averse in real life"
   - No psychological profiling
   - In-game behavior only

7. **Social Features**
   - No sharing to social media
   - No comparing with friends
   - No public profiles
   - Privacy-first

8. **Time-Based Analysis**
   - No "you played too fast/slow"
   - No real-time metrics
   - Turn-based only

9. **Meta-Progression**
   - No unlockables based on analysis
   - No achievements for archetypes
   - No gameplay rewards
   - Analysis is separate from game

10. **Dynamic Difficulty**
    - Analysis doesn't affect future games
    - No "game detected you're authoritarian, adjusting..."
    - Each run independent

## Formulas (Documented for Transparency)

### Meter Statistics

**Average:**
```dart
average = sum(values) / count(values)
```

**Trend (Linear Regression Slope):**
```dart
slope = (n * Σ(xy) - Σx * Σy) / (n * Σ(x²) - (Σx)²)
```

**Volatility (Variance):**
```dart
variance = Σ((value - average)²) / count
```

**Consistency (In Range):**
```dart
consistency = count(values in range) / total count
```

### Archetype Formulas

**Proactivity:**
```dart
score = 0.5
if reserves.avg > 0.5: score += 0.15
if stability.trend > 0: score += 0.10
if eventsPerTurn < 0.3: score += 0.15
// (Similar for reactive indicators)
return clamp(score, 0.0, 1.0)
```

**Control:**
```dart
score = 0.5
if stability.avg > 0.6 && morale.avg < 0.4: score += 0.3
if stability.avg > 0.65: score += 0.15
if morale.avg > 0.65: score -= 0.15
// (Similar for permissive indicators)
return clamp(score, 0.0, 1.0)
```

**Risk Tolerance:**
```dart
score = 0.5
if reserves.avg < 0.3: score += 0.3
if reserves.avg > 0.6: score -= 0.3
if reserves.volatility > 0.05: score += 0.10
return clamp(score, 0.0, 1.0)
```

**Information Seeking:**
```dart
score = 0.5
if clarity.avg > 0.65: score += 0.3
if clarity.trend > 0.02: score += 0.15
if clarity.avg > 0.6 && clarity.volatility < 0.03: score += 0.15
return clamp(score, 0.0, 1.0)
```

**Stability Focus:**
```dart
score = 0.5
if stability.avg > 0.6 && efficiency.avg < 0.4: score += 0.3
if efficiency.avg > 0.6 && stability.avg < 0.4: score -= 0.3
return clamp(score, 0.0, 1.0)
```

**Aggression:**
```dart
score = 0.5
if capacity.avg > 0.65: score += 0.25
if capacity.trend > 0.02 && stability.avg < 0.5: score += 0.20
if capacity.trend < -0.02: score -= 0.15
return clamp(score, 0.0, 1.0)
```

## Testing Strategy

### Determinism Tests

```dart
test('Same data produces same analysis', () {
  final data = createTestData();
  final report1 = AnalysisEngine.generateReport(data);
  final report2 = AnalysisEngine.generateReport(data);

  expect(report1.optimizations.length, equals(report2.optimizations.length));
  expect(report1.archetype.dimensions, equals(report2.archetype.dimensions));
});
```

### Threshold Tests

```dart
test('Tradeoff requires 0.20 gap', () {
  final data = createDataWithGap(0.19);
  final report = AnalysisEngine.generateReport(data);

  expect(report.optimizations.where((o) => o.isTradeoff), isEmpty);
});

test('Tradeoff detected with 0.20+ gap', () {
  final data = createDataWithGap(0.21);
  final report = AnalysisEngine.generateReport(data);

  expect(report.optimizations.where((o) => o.isTradeoff), isNotEmpty);
});
```

### Archetype Tests

```dart
test('High stability, low morale = authoritarian', () {
  final data = createDataWithStability(0.75, morale: 0.30);
  final report = AnalysisEngine.generateReport(data);

  final control = report.archetype.getScore(ArchetypeDimension.control);
  expect(control, greaterThan(0.6));
  expect(report.archetype.label, contains('Authoritarian'));
});

test('Balanced meters = balanced archetype', () {
  final data = createBalancedData();
  final report = AnalysisEngine.generateReport(data);

  final dimensions = report.archetype.dimensions.values;
  final allBalanced = dimensions.every((s) => s >= 0.4 && s <= 0.6);

  expect(allBalanced, isTrue);
  expect(report.archetype.label, contains('Balanced'));
});
```

### Neutrality Tests

```dart
test('No moral language in statements', () {
  final report = AnalysisEngine.generateReport(/* any data */);

  final bannedWords = ['good', 'bad', 'wrong', 'should', 'cruel', 'evil'];
  final allText = [
    ...report.optimizations.map((o) => o.statement),
    report.archetype.label,
    report.archetype.description,
  ].join(' ').toLowerCase();

  for (final word in bannedWords) {
    expect(allText, isNot(contains(word)));
  }
});

test('Archetype dimensions are symmetrical', () {
  // Both ends of scale should be used (not biased)
  final lowData = createLowMetersData();
  final highData = createHighMetersData();

  final lowReport = AnalysisEngine.generateReport(lowData);
  final highReport = AnalysisEngine.generateReport(highData);

  // Should get labels from both ends
  expect(lowReport.archetype.label, isNot(equals(highReport.archetype.label)));
});
```

## Edge Cases Handled

1. **Insufficient Data**
   - < 3 turns: Trend calculation returns 0.0 (stable)
   - Missing meters: Defaults to 0.5 (neutral)
   - No events: Event rate calculated as 0.0

2. **Extreme Values**
   - All meters at 1.0: Focus statements for each
   - All meters at 0.0: Neglect statements for each
   - All meters identical: "Balanced" archetype

3. **No Clear Patterns**
   - All balanced (0.4-0.6): Returns minimum statements (3)
   - Low confidence: Still included if best available
   - Neutral archetype: "Balanced Administrator"

4. **Contradictory Data**
   - High volatility with high average: Noted in evidence
   - Rising trend to low final: Trend takes precedence
   - Conflicting tradeoffs: Highest confidence wins

## Performance Considerations

- **Memory**: Meter history stored as List<double> per meter
  - 100 turns × 6 meters × 8 bytes = ~5KB
  - Negligible for modern devices

- **CPU**: Analysis is O(n) where n = number of turns
  - Linear regression: O(n)
  - Average calculation: O(n)
  - Total: < 1ms for 100 turns

- **Storage**: JSON report ~2-5KB
  - Text report ~1-2KB
  - Easily saved to file

## Future Enhancements (Not Implemented)

- Visualization: Meter graphs over time
- Comparison: Multiple runs side-by-side
- Export: Share as image or PDF
- Localization: Multi-language support
- Detailed breakdowns: Per-meter deep dives
- Historical tracking: Aggregate across multiple games
- Custom archetypes: Player-defined dimensions

## Version

- **Version**: 1.0
- **Date**: 2026-01-17
- **Items Implemented**: 48-50 (endgame analysis)
- **Dependencies**: None (pure analysis of data)
- **Status**: Complete, ready for integration
