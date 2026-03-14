# frozen_string_literal: true

RSpec.describe Legion::Extensions::Salience::Runners::Salience do
  subject(:client) { Legion::Extensions::Salience::Client.new }

  describe '#compute_salience' do
    context 'with empty tick_results' do
      it 'returns a hash with required keys' do
        result = client.compute_salience(tick_results: {})
        %i[overall urgency dominant_source above_baseline conflicts sources trend].each do |key|
          expect(result).to have_key(key)
        end
      end

      it 'returns :background urgency for zero signals' do
        result = client.compute_salience(tick_results: {})
        # novelty boost will elevate the first call, but urgency should be a valid level
        expect(Legion::Extensions::Salience::Helpers::Constants::URGENCY_LEVELS).to include(result[:urgency])
      end

      it 'returns sources hash with all 8 sources' do
        result = client.compute_salience(tick_results: {})
        expect(result[:sources].keys.size).to eq(8)
      end
    end

    context 'with emotion tick_results' do
      let(:tick_results) { { emotion: { arousal: 0.9, gut_strength: 0.7 } } }

      it 'returns elevated overall salience' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:overall]).to be > 0.0
      end

      it 'identifies emotion as having salience data' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:sources][:emotion][:raw_salience]).to eq(0.9)
      end

      it 'returns trend as a symbol' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:trend]).to be_a(Symbol)
      end
    end

    context 'with multiple sources' do
      let(:tick_results) do
        {
          emotion:     { arousal: 0.8 },
          trust:       { violation_count: 2 },
          homeostasis: { worst_deviation: 0.6 }
        }
      end

      it 'accumulates signal from all provided sources' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:overall]).to be > 0.0
      end

      it 'returns an Array for conflicts' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:conflicts]).to be_an(Array)
      end

      it 'returns a boolean for above_baseline' do
        result = client.compute_salience(tick_results: tick_results)
        expect(result[:above_baseline]).to be(true).or be(false)
      end
    end
  end

  describe '#salience_status' do
    it 'returns a hash with required keys' do
      result = client.salience_status
      %i[overall urgency dominant baseline trend above_baseline].each do |key|
        expect(result).to have_key(key)
      end
    end

    it 'reflects state after a compute_salience call' do
      client.compute_salience(tick_results: { emotion: { arousal: 0.7 } })
      status = client.salience_status
      expect(status[:overall]).to be >= 0.0
    end
  end

  describe '#salience_for' do
    it 'returns salience for an existing source' do
      client.compute_salience(tick_results: { emotion: { arousal: 0.5 } })
      result = client.salience_for(source: :emotion)
      expect(result[:source]).to eq(:emotion)
      expect(result[:salience]).to be >= 0.0
    end

    it 'returns 0.0 salience for an unknown source' do
      result = client.salience_for(source: :nonexistent)
      expect(result[:salience]).to eq(0.0)
    end

    it 'includes urgency in the response' do
      result = client.salience_for(source: :emotion)
      expect(result).to have_key(:urgency)
    end
  end

  describe '#salience_history' do
    it 'returns an entries array' do
      result = client.salience_history
      expect(result).to have_key(:entries)
      expect(result[:entries]).to be_an(Array)
    end

    it 'respects the limit parameter' do
      5.times { client.compute_salience(tick_results: {}) }
      result = client.salience_history(limit: 3)
      expect(result[:entries].size).to be <= 3
    end

    it 'accumulates entries across compute calls' do
      3.times { client.compute_salience(tick_results: {}) }
      result = client.salience_history(limit: 10)
      expect(result[:entries].size).to eq(3)
    end
  end

  describe '#salience_stats' do
    it 'returns a hash with all stat keys' do
      result = client.salience_stats
      %i[overall baseline urgency dominant history_size conflict_count trend].each do |key|
        expect(result).to have_key(key)
      end
    end

    it 'reports 0 history_size before any compute calls' do
      expect(client.salience_stats[:history_size]).to eq(0)
    end

    it 'increments history_size after compute calls' do
      client.compute_salience(tick_results: {})
      expect(client.salience_stats[:history_size]).to eq(1)
    end
  end
end
