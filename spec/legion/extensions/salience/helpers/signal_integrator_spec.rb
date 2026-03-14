# frozen_string_literal: true

RSpec.describe Legion::Extensions::Salience::Helpers::SignalIntegrator do
  describe '.integrate' do
    context 'with empty tick_results' do
      it 'returns a hash with all 8 sources' do
        result = described_class.integrate(tick_results: {})
        expect(result.keys.size).to eq(8)
      end

      it 'sets raw_salience to 0.0 for all sources' do
        result = described_class.integrate(tick_results: {})
        result.each_value do |v|
          expect(v[:raw_salience]).to eq(0.0)
        end
      end

      it 'sets weighted to 0.0 for all sources' do
        result = described_class.integrate(tick_results: {})
        result.each_value do |v|
          expect(v[:weighted]).to eq(0.0)
        end
      end
    end

    context 'with emotion data' do
      let(:tick_results) { { emotion: { arousal: 0.8, gut_strength: 0.6 } } }

      it 'extracts max of arousal and gut_strength as raw_salience' do
        result = described_class.integrate(tick_results: tick_results)
        expect(result[:emotion][:raw_salience]).to eq(0.8)
      end

      it 'applies the emotion weight (0.20)' do
        result = described_class.integrate(tick_results: tick_results)
        expect(result[:emotion][:weighted]).to be_within(0.0001).of(0.8 * 0.20)
      end

      it 'stores the raw signal_data' do
        result = described_class.integrate(tick_results: tick_results)
        expect(result[:emotion][:signal_data]).to eq({ arousal: 0.8, gut_strength: 0.6 })
      end
    end

    context 'with mood data' do
      it 'computes 1.0 - stability as raw_salience' do
        result = described_class.integrate(tick_results: { mood: { stability: 0.3 } })
        expect(result[:mood][:raw_salience]).to be_within(0.001).of(0.7)
      end

      it 'defaults stability to 1.0 when missing (0.0 salience)' do
        result = described_class.integrate(tick_results: { mood: {} })
        expect(result[:mood][:raw_salience]).to eq(0.0)
      end
    end

    context 'with attention data' do
      it 'computes spotlight_count / total' do
        result = described_class.integrate(tick_results: { attention: { spotlight_count: 3, total: 10 } })
        expect(result[:attention][:raw_salience]).to be_within(0.001).of(0.3)
      end

      it 'guards against zero total' do
        result = described_class.integrate(tick_results: { attention: { spotlight_count: 0, total: 0 } })
        expect(result[:attention][:raw_salience]).to eq(0.0)
      end
    end

    context 'with homeostasis data' do
      it 'uses worst_deviation clamped to 0-1' do
        result = described_class.integrate(tick_results: { homeostasis: { worst_deviation: 0.6 } })
        expect(result[:homeostasis][:raw_salience]).to eq(0.6)
      end

      it 'clamps values above 1.0' do
        result = described_class.integrate(tick_results: { homeostasis: { worst_deviation: 1.5 } })
        expect(result[:homeostasis][:raw_salience]).to eq(1.0)
      end
    end

    context 'with trust data' do
      it 'computes violation_count * 0.3 clamped to 0-1' do
        result = described_class.integrate(tick_results: { trust: { violation_count: 2 } })
        expect(result[:trust][:raw_salience]).to be_within(0.001).of(0.6)
      end

      it 'clamps at 1.0 for many violations' do
        result = described_class.integrate(tick_results: { trust: { violation_count: 10 } })
        expect(result[:trust][:raw_salience]).to eq(1.0)
      end
    end

    context 'with empathy data' do
      it 'returns 1.0 for adversarial climate' do
        result = described_class.integrate(tick_results: { empathy: { climate: :adversarial } })
        expect(result[:empathy][:raw_salience]).to eq(1.0)
      end

      it 'returns 0.5 for tense climate' do
        result = described_class.integrate(tick_results: { empathy: { climate: :tense } })
        expect(result[:empathy][:raw_salience]).to eq(0.5)
      end

      it 'returns 0.1 for neutral climate' do
        result = described_class.integrate(tick_results: { empathy: { climate: :neutral } })
        expect(result[:empathy][:raw_salience]).to eq(0.1)
      end

      it 'returns 0.0 for harmonious climate' do
        result = described_class.integrate(tick_results: { empathy: { climate: :harmonious } })
        expect(result[:empathy][:raw_salience]).to eq(0.0)
      end

      it 'returns 0.0 for unknown climate' do
        result = described_class.integrate(tick_results: { empathy: { climate: :unknown } })
        expect(result[:empathy][:raw_salience]).to eq(0.0)
      end
    end

    context 'with volition data' do
      it 'uses intention_salience as raw_salience' do
        result = described_class.integrate(tick_results: { volition: { intention_salience: 0.75 } })
        expect(result[:volition][:raw_salience]).to eq(0.75)
      end
    end

    context 'with multiple sources' do
      let(:tick_results) do
        {
          emotion:     { arousal: 0.9 },
          homeostasis: { worst_deviation: 0.5 },
          trust:       { violation_count: 1 }
        }
      end

      it 'returns all 8 sources regardless of which are provided' do
        result = described_class.integrate(tick_results: tick_results)
        expect(result.keys.size).to eq(8)
      end

      it 'correctly weights multiple sources' do
        result = described_class.integrate(tick_results: tick_results)
        expect(result[:emotion][:weighted]).to be_within(0.001).of(0.9 * 0.20)
        expect(result[:homeostasis][:weighted]).to be_within(0.001).of(0.5 * 0.15)
        expect(result[:trust][:weighted]).to be_within(0.001).of(0.3 * 0.10)
      end
    end
  end
end
