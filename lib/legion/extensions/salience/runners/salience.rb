# frozen_string_literal: true

module Legion
  module Extensions
    module Salience
      module Runners
        module Salience
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def compute_salience(tick_results: {}, **)
            integrated = Helpers::SignalIntegrator.integrate(tick_results: tick_results)
            salience_map.update(integrated)

            Legion::Logging.debug "[salience] compute: overall=#{salience_map.overall_salience.round(3)} " \
                                  "urgency=#{salience_map.urgency_level} dominant=#{salience_map.dominant_source}"

            {
              overall:         salience_map.overall_salience,
              urgency:         salience_map.urgency_level,
              dominant_source: salience_map.dominant_source,
              above_baseline:  salience_map.above_baseline?,
              conflicts:       salience_map.conflict_signals,
              sources:         integrated,
              trend:           salience_map.salience_trend
            }
          end

          def salience_status(**)
            Legion::Logging.debug "[salience] status: urgency=#{salience_map.urgency_level} trend=#{salience_map.salience_trend}"
            {
              overall:        salience_map.overall_salience,
              urgency:        salience_map.urgency_level,
              dominant:       salience_map.dominant_source,
              baseline:       salience_map.baseline,
              trend:          salience_map.salience_trend,
              above_baseline: salience_map.above_baseline?
            }
          end

          def salience_for(source:, **)
            data = salience_map.current_map[source]
            Legion::Logging.debug "[salience] salience_for: source=#{source} salience=#{data || 0.0}"
            { source: source, salience: data || 0.0, urgency: salience_map.urgency_level }
          end

          def salience_history(limit: 10, **)
            { entries: salience_map.history.last(limit) }
          end

          def salience_stats(**)
            {
              overall:        salience_map.overall_salience,
              baseline:       salience_map.baseline,
              urgency:        salience_map.urgency_level,
              dominant:       salience_map.dominant_source,
              history_size:   salience_map.history.size,
              conflict_count: salience_map.conflict_signals.size,
              trend:          salience_map.salience_trend
            }
          end
        end
      end
    end
  end
end
