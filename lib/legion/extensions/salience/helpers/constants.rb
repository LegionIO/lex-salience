# frozen_string_literal: true

module Legion
  module Extensions
    module Salience
      module Helpers
        module Constants
          SALIENCE_SOURCES = %i[emotion mood attention curiosity homeostasis trust empathy volition].freeze

          SOURCE_WEIGHTS = {
            emotion:     0.20,
            mood:        0.10,
            attention:   0.15,
            curiosity:   0.15,
            homeostasis: 0.15,
            trust:       0.10,
            empathy:     0.05,
            volition:    0.10
          }.freeze

          URGENCY_LEVELS = %i[critical high moderate low background].freeze

          URGENCY_THRESHOLDS = {
            critical:   0.9,
            high:       0.7,
            moderate:   0.4,
            low:        0.2,
            background: 0.0
          }.freeze

          MAX_SALIENCE_ITEMS  = 10
          SALIENCE_DECAY_RATE = 0.05
          INTEGRATION_ALPHA   = 0.3
          NOVELTY_BOOST       = 0.2
          CONFLICT_AMPLIFIER  = 1.5
        end
      end
    end
  end
end
