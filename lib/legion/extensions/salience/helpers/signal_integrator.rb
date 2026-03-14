# frozen_string_literal: true

module Legion
  module Extensions
    module Salience
      module Helpers
        module SignalIntegrator
          module_function

          def integrate(tick_results: {})
            Constants::SALIENCE_SOURCES.each_with_object({}) do |source, result|
              data   = tick_results.fetch(source, {}) || {}
              raw    = extract_raw(source, data)
              weight = Constants::SOURCE_WEIGHTS.fetch(source, 0.0)

              result[source] = {
                raw_salience: raw,
                weighted:     (raw * weight).round(6),
                signal_data:  data
              }
            end
          end

          def extract_raw(source, data)
            case source
            when :emotion     then extract_emotion(data)
            when :mood        then extract_mood(data)
            when :attention   then extract_attention(data)
            when :curiosity   then extract_curiosity(data)
            when :homeostasis then extract_homeostasis(data)
            when :trust       then extract_trust(data)
            when :empathy     then extract_empathy(data)
            when :volition    then extract_volition(data)
            else 0.0
            end
          end

          def extract_emotion(data)
            arousal      = (data[:arousal] || 0.0).to_f
            gut_strength = (data[:gut_strength] || 0.0).to_f
            clamp([arousal, gut_strength].max)
          end

          def extract_mood(data)
            stability = (data[:stability] || 1.0).to_f
            clamp(1.0 - stability)
          end

          def extract_attention(data)
            spotlight_count = (data[:spotlight_count] || 0).to_f
            total           = [(data[:total] || 0).to_f, 1.0].max
            clamp(spotlight_count / total)
          end

          def extract_curiosity(data)
            top_salience = (data[:top_salience] || 0.0).to_f
            clamp(top_salience)
          end

          def extract_homeostasis(data)
            worst_deviation = (data[:worst_deviation] || 0.0).to_f
            clamp(worst_deviation)
          end

          def extract_trust(data)
            violation_count = (data[:violation_count] || 0).to_f
            clamp(violation_count * 0.3)
          end

          EMPATHY_CLIMATE_SCORES = {
            adversarial: 1.0,
            tense:       0.5,
            neutral:     0.1,
            harmonious:  0.0
          }.freeze

          def extract_empathy(data)
            EMPATHY_CLIMATE_SCORES.fetch(data[:climate], 0.0)
          end

          def extract_volition(data)
            intention_salience = (data[:intention_salience] || 0.0).to_f
            clamp(intention_salience)
          end

          def clamp(value, min = 0.0, max = 1.0)
            value.clamp(min, max)
          end
        end
      end
    end
  end
end
