# Endgame Analysis - Give (Me)

## Overview

The Endgame Analysis system generates a post-game report that reveals player priorities and behavioral patterns WITHOUT moral judgment. It shows **what** the player optimized for based on **observable data**, not subjective interpretation.

## Core Principles

1. **Descriptive, Not Prescriptive**
   - "You prioritized stability" not "You should have prioritized stability"
   - Observable patterns, not value judgments

2. **Evidence-Based**
   - Every conclusion cites specific data
   - Thresholds are transparent and deterministic
   - Same behavior = same analysis every time

3. **Neutral Language**
   - No "good" or "bad"
   - No moral labels ("cruel", "kind", "selfish")
   - Behavioral descriptors only ("reactive", "proactive", "authoritarian")

## Report Components

### 1. Run Summary
Basic facts about the game:
- Turns survived
- Scenario name
- Difficulty level
- End condition (if applicable)
- Final meter values
- Total events

### 2. Optimization Statements (3-5)
What the player prioritized, with evidence:

**Examples:**
- "You prioritized stability over morale"
  - Evidence: stability avg 0.72, morale avg 0.35

- "You traded reserves for capacity"
  - Evidence: reserves avg 0.28, capacity avg 0.68

- "You maintained clarity throughout"
  - Evidence: clarity avg 0.74, volatility 0.02

### 3. Archetype Classification
Behavioral dimensions (0.0-1.0 scale):

**Six Dimensions:**
1. **Proactivity** (Reactive ←→ Proactive)
   - Based on: reserves, stability trend, crisis frequency

2. **Control** (Permissive ←→ Authoritarian)
   - Based on: stability vs morale tradeoff

3. **Risk Tolerance** (Risk-Averse ←→ Risk-Tolerant)
   - Based on: reserves level, volatility

4. **Information Seeking** (Intuition-Driven ←→ Information-Driven)
   - Based on: clarity level, trend

5. **Stability Focus** (Efficiency-Focused ←→ Stability-Focused)
   - Based on: stability vs efficiency tradeoff

6. **Aggression** (Conservative ←→ Aggressive)
   - Based on: capacity, growth patterns

**Label Generation:**
Combines dominant dimensions into neutral descriptor:
- "Proactive Risk-Averse Administrator"
- "Reactive Authoritarian Administrator"
- "Balanced Administrator"

## Architecture

### Models

**EndgameReport**
- Complete analysis package
- Run summary + optimizations + archetype
- JSON serializable

**OptimizationStatement**
- What player optimized for
- Evidence supporting conclusion
- Confidence level (0.0-1.0)

**Archetype**
- Six behavioral dimensions
- Evidence for each dimension
- Generated label and description

**Evidence**
- Type (meter level, trend, pattern, etc.)
- Observation (what was observed)
- Value and threshold (numerical support)
- Timeframe (when it occurred)

### Analyzers

**MeterAnalyzer**
- Calculate averages, trends, volatility
- Detect patterns in meter history
- Generate meter-based evidence

**ArchetypeAnalyzer**
- Calculate dimension scores
- Generate dimension-specific evidence
- Deterministic formulas

**OptimizationAnalyzer**
- Detect tradeoffs (X over Y)
- Detect focus areas (high/low emphasis)
- Detect trend patterns (building up X)
- Select best statements

### AnalysisEngine
- Main orchestrator
- Generates complete report
- Combines all analyzers

## Integration Guide

### Step 1: Track Meter History During Game

```dart
class GameManager {
  // Track meter values each turn
  final List<Map<String, double>> meterHistory = [];

  void onTurnEnd() {
    // Record current meter values
    meterHistory.add({
      'stability': gameState.getMeter('stability').value,
      'capacity': gameState.getMeter('capacity').value,
      'reserves': gameState.getMeter('reserves').value,
      'clarity': gameState.getMeter('clarity').value,
      'morale': gameState.getMeter('morale').value,
      'efficiency': gameState.getMeter('efficiency').value,
    });

    // ... rest of turn logic
  }
}
```

### Step 2: Generate Report at Game End

```dart
Future<void> onGameEnd({String? endCondition}) async {
  final report = AnalysisEngine.generateFromGameState(
    turnsSurvived: currentTurn,
    scenarioId: currentScenario.id,
    difficultyId: currentDifficulty.id,
    finalMeters: {
      'stability': gameState.getMeter('stability').value,
      'capacity': gameState.getMeter('capacity').value,
      'reserves': gameState.getMeter('reserves').value,
      'clarity': gameState.getMeter('clarity').value,
      'morale': gameState.getMeter('morale').value,
      'efficiency': gameState.getMeter('efficiency').value,
    },
    turnByTurnMeters: meterHistory,
    endCondition: endCondition,
    totalEvents: eventEngine.eventLog.length,
  );

  // Show report to player
  showEndgameReport(report);

  // Optionally save to file
  await saveReportToFile(report);
}
```

### Step 3: Display Report (UI)

```dart
class EndgameReportScreen extends StatelessWidget {
  final EndgameReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Endgame Analysis')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary section
            _buildSummarySection(),

            SizedBox(height: 24),

            // Optimizations section
            Text('What You Optimized For',
                style: Theme.of(context).textTheme.headline6),
            ...report.optimizations.map(_buildOptimizationCard),

            SizedBox(height: 24),

            // Archetype section
            Text('Your Approach',
                style: Theme.of(context).textTheme.headline6),
            _buildArchetypeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCard(OptimizationStatement opt) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opt.statement,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Evidence:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ...opt.evidence.take(2).map((e) =>
              Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Text('• ${e.observation}',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
            SizedBox(height: 4),
            Text('Confidence: ${opt.confidencePercent}%',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildArchetypeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.archetype.label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(report.archetype.description),
            SizedBox(height: 16),
            ...report.archetype.dimensions.entries.map((entry) =>
              _buildDimensionBar(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionBar(ArchetypeDimension dimension, double score) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dimension.getLabelForScore(score),
              style: TextStyle(fontSize: 12)),
          SizedBox(height: 2),
          LinearProgressIndicator(
            value: score,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForScore(score),
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dimension.lowLabel,
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(dimension.highLabel,
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForScore(double score) {
    // Neutral colors - no "good" or "bad"
    if (score < 0.4) return Colors.blue;
    if (score > 0.6) return Colors.purple;
    return Colors.teal;
  }
}
```

### Step 4: Save Report (Optional)

```dart
Future<void> saveReportToFile(EndgameReport report) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/reports/report_${DateTime.now().millisecondsSinceEpoch}.json');

  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(report.toJson()));
}

Future<void> saveReportAsText(EndgameReport report) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/reports/report_${DateTime.now().millisecondsSinceEpoch}.txt');

  await file.parent.create(recursive: true);
  await file.writeAsString(report.toReadableReport());
}
```

## Formulas & Thresholds

All analysis is deterministic. Here are the key formulas:

### Optimization Detection

**Tradeoff Detection:**
```dart
diff = meter1.average - meter2.average;

if (abs(diff) >= 0.20 && // Significant gap
    prioritized.average >= 0.60 && // High enough
    sacrificed.average <= 0.40) { // Low enough
  // Tradeoff detected
  confidence = (abs(diff) - 0.20) / 0.80;
}
```

**Focus Area Detection:**
```dart
// Highly prioritized
if (meter.average >= 0.70) {
  confidence = (meter.average - 0.70) / 0.30;
  statement = "You emphasized {meter}";
}

// Neglected
if (meter.average <= 0.30) {
  confidence = (0.30 - meter.average) / 0.30;
  statement = "You deprioritized {meter}";
}
```

### Archetype Dimensions

**Proactivity** (Reactive 0.0 ←→ Proactive 1.0):
```dart
score = 0.5; // Start neutral

if (reserves.avg > 0.5) score += 0.15;
if (stability.trend > 0) score += 0.10;
if (eventsPerTurn < 0.3) score += 0.15;

// (Reverse for reactive indicators)
```

**Control** (Permissive 0.0 ←→ Authoritarian 1.0):
```dart
score = 0.5;

if (stability.avg > 0.6 && morale.avg < 0.4) {
  score += 0.3; // High control, low freedom
}

if (stability.avg > 0.65) score += 0.15;
// (Similar for permissive indicators)
```

**Risk Tolerance** (Risk-Averse 0.0 ←→ Risk-Tolerant 1.0):
```dart
score = 0.5;

if (reserves.avg < 0.3) score += 0.3; // Low reserves = risky
if (reserves.avg > 0.6) score -= 0.3; // High reserves = cautious

if (reserves.volatility > 0.05) score += 0.10;
```

**Information Seeking** (Intuition 0.0 ←→ Data-Driven 1.0):
```dart
score = 0.5;

if (clarity.avg > 0.65) score += 0.3;
if (clarity.trend > 0.02) score += 0.15;
if (clarity.avg > 0.6 && clarity.volatility < 0.03) {
  score += 0.15; // Stable high clarity
}
```

## Avoiding Preachy Analysis

### What We DON'T Do

❌ **Moral Judgment**
- Bad: "You were too cruel to your people"
- Good: "You prioritized stability over morale"

❌ **Should/Could Statements**
- Bad: "You should have invested in reserves"
- Good: "You operated with low reserves"

❌ **Value-Laden Labels**
- Bad: "Selfish Dictator"
- Good: "Authoritarian Risk-Tolerant Administrator"

❌ **Blame Language**
- Bad: "You failed to maintain morale"
- Good: "Morale remained low throughout"

❌ **Implicit Ranking**
- Bad: "You chose the wrong priority"
- Good: "You prioritized X over Y"

### What We DO

✅ **Observable Behavior**
- "You maintained high stability"
- "You traded reserves for capacity"

✅ **Neutral Descriptors**
- "Reactive" not "lazy"
- "Authoritarian" not "tyrant"
- "Risk-tolerant" not "reckless"

✅ **Evidence-Based**
- Every statement cites data
- Thresholds shown
- Confidence levels displayed

✅ **Symmetrical Language**
- "Permissive" ←→ "Authoritarian" (both neutral)
- "Reactive" ←→ "Proactive" (both valid)
- "Risk-Averse" ←→ "Risk-Tolerant" (both strategies)

## Testing

### Test Different Play Styles

```dart
test('High stability, low morale = authoritarian', () {
  final report = AnalysisEngine.generateReport(
    // ... setup with high stability, low morale
  );

  final controlScore = report.archetype.getScore(ArchetypeDimension.control);
  expect(controlScore, greaterThan(0.6)); // Authoritarian end
});

test('Tradeoff detection requires threshold', () {
  final report = AnalysisEngine.generateReport(
    // ... setup with small difference
  );

  // Should NOT detect tradeoff if difference < 0.20
  expect(
    report.optimizations.where((o) => o.isTradeoff).length,
    equals(0),
  );
});

test('Same data = same analysis (deterministic)', () {
  final report1 = AnalysisEngine.generateReport(/* ... */);
  final report2 = AnalysisEngine.generateReport(/* same data */);

  expect(report1.optimizations.length, equals(report2.optimizations.length));
  expect(report1.archetype.label, equals(report2.archetype.label));
});
```

## Example Output

```
═══════════════════════════════════════
         ENDGAME ANALYSIS
═══════════════════════════════════════

RUN SUMMARY
───────────────────────────────────────
Turns Survived: 42
Scenario: Hardline City
Difficulty: Standard
Ended: Stability collapse

WHAT YOU OPTIMIZED FOR
───────────────────────────────────────
1. You prioritized stability over morale
   Evidence:
   • stability average: maintained high (0.73 vs threshold 0.60)
   • morale average: remained low (0.32 vs threshold 0.40)

2. You maintained clarity throughout
   Evidence:
   • clarity average: maintained very high (0.78 vs threshold 0.70)
   • clarity kept stable (0.02 vs threshold 0.03)

3. You traded reserves for capacity
   Evidence:
   • capacity average: maintained high (0.69 vs threshold 0.60)
   • reserves average: remained low (0.28 vs threshold 0.40)

YOUR APPROACH
───────────────────────────────────────
Classification: Proactive Authoritarian Administrator
Managed by: prevented crises before they emerged, maintained order through strong oversight, prioritized clear information.

Behavioral Dimensions:
  Proactive [████████████████░░░░] 80%
  Authoritarian [██████████████░░░░░░] 70%
  Risk-Tolerant [███████████░░░░░░░░░] 55%
  Information-Driven [████████████████░░░░] 80%
  Stability-Focused [███████████████░░░░░] 75%
  Moderate Pace [██████████░░░░░░░░░░] 50%

═══════════════════════════════════════
```

## Summary

The Endgame Analysis provides:
- **Transparent**: Shows the data behind conclusions
- **Neutral**: No moral judgment or "right way" to play
- **Deterministic**: Same behavior = same analysis
- **Insightful**: Reveals patterns player might not notice
- **Respectful**: Describes, doesn't prescribe

It's a mirror, not a judge.
