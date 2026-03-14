# lex-salience

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-salience`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::Salience`

## Purpose

Weighted salience integration from multiple cognitive sources. Extracts signals from eight cognitive subsystems (emotion, mood, attention, curiosity, homeostasis, trust, empathy, volition) via `SignalIntegrator`, weights them by `SOURCE_WEIGHTS`, and updates a `SalienceMap`. The map tracks overall salience, urgency level, dominant source, baseline (EMA), trend, and conflicting signal pairs (pairs with > 0.3 divergence). First appearance of any source receives a novelty boost.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-salience
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/salience/
  version.rb
  client.rb
  helpers/
    constants.rb        # SALIENCE_SOURCES, SOURCE_WEIGHTS, URGENCY_LEVELS/THRESHOLDS, limits
    salience_map.rb     # SalienceMap — weighted map with baseline, trend, conflicts
    signal_integrator.rb  # SignalIntegrator — extracts and normalizes per-source signals
  runners/
    salience.rb         # Runner module
spec/
  helpers/constants_spec.rb
  helpers/salience_map_spec.rb
  helpers/signal_integrator_spec.rb
  runners/salience_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `SALIENCE_SOURCES = %i[emotion mood attention curiosity homeostasis trust empathy volition]`
- `SOURCE_WEIGHTS = { emotion: 0.20, mood: 0.10, attention: 0.15, curiosity: 0.15, homeostasis: 0.15, trust: 0.10, empathy: 0.05, volition: 0.10 }`
- `URGENCY_LEVELS = %i[critical high moderate low background]`
- `URGENCY_THRESHOLDS = { critical: 0.9, high: 0.7, moderate: 0.4, low: 0.2, background: 0.0 }`
- `MAX_SALIENCE_ITEMS = 10`, `SALIENCE_DECAY_RATE = 0.05`, `INTEGRATION_ALPHA = 0.3`
- `NOVELTY_BOOST = 0.2`, `CONFLICT_AMPLIFIER = 1.5`

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `compute_salience` | `tick_results: {}` | overall, urgency, dominant_source, above_baseline, conflicts, sources, trend |
| `salience_status` | — | overall, urgency, dominant, baseline, trend, above_baseline |
| `salience_for` | `source:` | `{ source:, salience:, urgency: }` |
| `salience_history` | `limit: 10` | `{ entries: }` last N snapshots |
| `salience_stats` | — | overall, baseline, urgency, dominant, history_size, conflict_count, trend |

## Helpers

### `Helpers::SignalIntegrator`
`module_function`. `integrate(tick_results:)` reads each of the 8 source keys from tick_results, normalizes to 0–1, and returns a hash of `{ source: { raw:, weighted: } }`. Weighted = raw * `SOURCE_WEIGHTS[source]`.

### `Helpers::SalienceMap`
Manages `@current_map` (source -> weighted value), `@baseline` (EMA), `@history` (capped at 50). `update(integrated_signals)` applies novelty boost on first encounter per source, computes overall salience (sum of weighted values), updates baseline via EMA. Appends snapshot to history. `overall_salience` = sum of current_map values. `urgency_level` scans `URGENCY_LEVELS` for first threshold met. `dominant_source` = highest-salience source. `above_baseline?` = overall > baseline. `conflict_signals` = pairs where abs(a - b) > 0.3. `salience_trend` = `:rising`/`:falling`/`:stable` based on last 5 snapshots delta.

## Integration Points

- `compute_salience` is the canonical integration hub — called each tick via `lex-cortex`
- Reads from `tick_results[:emotional_evaluation]` for emotion source
- Reads from `tick_results[:working_memory_integration]` for curiosity/attention
- Reads from `tick_results[:trust]` for trust source
- `:critical` urgency can trigger `lex-extinction` emergency protocol
- `dominant_source` feeds `lex-tick`'s `action_selection` phase to bias toward pressing needs
- `conflict_signals` pairs can trigger `lex-conflict` registration
- `above_baseline?` = `true` can heighten `lex-emotion` arousal

## Development Notes

- `INTEGRATION_ALPHA = 0.3` for baseline EMA — faster than most other EMAs in the system
- Novelty boost applied only on first encounter per source; `@novel_sources` is never cleared
- Conflict detection threshold: abs(a - b) > 0.3 (pairs only, O(n^2))
- Trend window is 5 snapshots; delta threshold is 0.02
- `overall_salience` = raw sum of weighted values (not normalized to 1.0)
- All state is in-memory; reset on process restart
