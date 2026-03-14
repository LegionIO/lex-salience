# lex-salience

Weighted salience integration for the LegionIO cognitive architecture. Combines signals from eight cognitive subsystems into a unified urgency assessment.

## What It Does

Integrates salience signals from emotion, mood, attention, curiosity, homeostasis, trust, empathy, and volition into a single weighted map. Each source is normalized and weighted by its cognitive importance. The map tracks overall salience, urgency level, which source is dominant, and whether the current state is above the baseline. Detects conflicting signal pairs and trends over time. New sources receive a one-time novelty boost on first appearance.

## Usage

```ruby
client = Legion::Extensions::Salience::Client.new

# Compute salience from tick results
result = client.compute_salience(
  tick_results: {
    emotional_evaluation:       { arousal: 0.8, valence: -0.3 },
    working_memory_integration: { curiosity_intensity: 0.7, gaps_detected: 3 },
    trust:                      { composite: 0.6 },
    homeostasis:                { worst_deviation: 0.2 }
  }
)
# => { overall: 0.48, urgency: :moderate, dominant_source: :emotion,
#      above_baseline: true, conflicts: [], sources: { ... }, trend: :rising }

# Current status
client.salience_status
# => { overall: 0.48, urgency: :moderate, dominant: :emotion,
#      baseline: 0.31, trend: :rising, above_baseline: true }

# Per-source salience
client.salience_for(source: :curiosity)
# => { source: :curiosity, salience: 0.105, urgency: :moderate }

# History and stats
client.salience_history(limit: 5)
client.salience_stats
```

## Sources and Weights

| Source | Weight |
|--------|--------|
| `emotion` | 0.20 |
| `attention` | 0.15 |
| `curiosity` | 0.15 |
| `homeostasis` | 0.15 |
| `mood` | 0.10 |
| `trust` | 0.10 |
| `volition` | 0.10 |
| `empathy` | 0.05 |

## Urgency Levels

`:critical` (>= 0.9), `:high` (>= 0.7), `:moderate` (>= 0.4), `:low` (>= 0.2), `:background`

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
