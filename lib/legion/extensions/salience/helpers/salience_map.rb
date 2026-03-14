# frozen_string_literal: true

module Legion
  module Extensions
    module Salience
      module Helpers
        class SalienceMap
          attr_reader :current_map, :baseline, :history

          MAX_HISTORY   = 50
          TREND_WINDOW  = 5
          TREND_DELTA   = 0.02

          def initialize
            @current_map   = {}
            @baseline      = 0.0
            @history       = []
            @novel_sources = {}
          end

          def update(integrated_signals)
            @current_map = integrated_signals.transform_values { |v| v[:weighted] }
            apply_novelty_boost(integrated_signals)
            overall = overall_salience
            @baseline = (Constants::INTEGRATION_ALPHA * overall) + ((1.0 - Constants::INTEGRATION_ALPHA) * @baseline)
            snapshot = {
              timestamp:    Time.now.utc.to_f,
              overall:      overall,
              urgency:      urgency_level,
              dominant:     dominant_source,
              map_snapshot: @current_map.dup
            }
            @history << snapshot
            @history.shift while @history.size > MAX_HISTORY
            snapshot
          end

          def overall_salience
            @current_map.values.sum.round(6)
          end

          def urgency_level
            score = overall_salience
            Constants::URGENCY_LEVELS.find do |level|
              score >= Constants::URGENCY_THRESHOLDS[level]
            end || :background
          end

          def dominant_source
            return nil if @current_map.empty?

            @current_map.max_by { |_k, v| v }&.first
          end

          def above_baseline?
            overall_salience > @baseline
          end

          def conflict_signals
            values = @current_map.values
            return [] if values.size < 2

            pairs = []
            keys  = @current_map.keys
            keys.each_with_index do |key_a, i|
              keys[(i + 1)..].each do |key_b|
                diff = (@current_map[key_a] - @current_map[key_b]).abs
                pairs << [key_a, key_b] if diff > 0.3
              end
            end
            pairs
          end

          def salience_trend
            return :stable if @history.size < 2

            window   = @history.last([TREND_WINDOW, @history.size].min).map { |h| h[:overall] }
            delta    = window.last - window.first
            if delta > TREND_DELTA
              :rising
            elsif delta < -TREND_DELTA
              :falling
            else
              :stable
            end
          end

          def to_h
            {
              current_map:    @current_map,
              overall:        overall_salience,
              baseline:       @baseline,
              urgency:        urgency_level,
              dominant:       dominant_source,
              above_baseline: above_baseline?,
              conflicts:      conflict_signals,
              trend:          salience_trend,
              history_size:   @history.size
            }
          end

          private

          def apply_novelty_boost(integrated_signals)
            integrated_signals.each_key do |source|
              next if @novel_sources.key?(source)

              @novel_sources[source] = true
              current = @current_map[source] || 0.0
              boosted = [current + Constants::NOVELTY_BOOST, 1.0].min
              @current_map[source] = boosted
            end
          end
        end
      end
    end
  end
end
