# lex-salience

Unified Salience Network for the LegionIO cognitive architecture.

Models the brain's salience network — the integrator that determines "what matters most RIGHT NOW" by reading signals from all other cognitive subsystems and computing a unified priority signal.

## Overview

`lex-salience` integrates signals from 8 cognitive sources (emotion, mood, attention, curiosity, homeostasis, trust, empathy, volition), applies weighted combination, and produces a unified urgency classification.

## Installation

Add to your Gemfile:

```ruby
gem 'legion-extensions-salience'
```

## Usage

```ruby
client = Legion::Extensions::Salience::Client.new

result = client.compute_salience(tick_results: {
  emotion:     { arousal: 0.8, gut_strength: 0.6 },
  homeostasis: { worst_deviation: 0.7 }
})

result[:urgency]         # => :high
result[:dominant_source] # => :emotion
result[:above_baseline]  # => true
```

## License

MIT License. Copyright (c) 2026 Matthew Iverson.
