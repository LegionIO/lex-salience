# frozen_string_literal: true

RSpec.describe Legion::Extensions::Salience::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a default SalienceMap' do
      expect(client.salience_map).to be_a(Legion::Extensions::Salience::Helpers::SalienceMap)
    end

    it 'accepts an injected salience_map' do
      custom_map = Legion::Extensions::Salience::Helpers::SalienceMap.new
      injected   = described_class.new(salience_map: custom_map)
      expect(injected.salience_map).to be(custom_map)
    end
  end

  describe 'runner method delegation' do
    it 'responds to compute_salience' do
      expect(client).to respond_to(:compute_salience)
    end

    it 'responds to salience_status' do
      expect(client).to respond_to(:salience_status)
    end

    it 'responds to salience_for' do
      expect(client).to respond_to(:salience_for)
    end

    it 'responds to salience_history' do
      expect(client).to respond_to(:salience_history)
    end

    it 'responds to salience_stats' do
      expect(client).to respond_to(:salience_stats)
    end
  end

  describe 'stateful behavior' do
    it 'accumulates history across multiple calls' do
      client.compute_salience(tick_results: {})
      client.compute_salience(tick_results: { emotion: { arousal: 0.5 } })
      expect(client.salience_map.history.size).to eq(2)
    end

    it 'uses the same salience_map instance across calls' do
      map_before = client.salience_map
      client.compute_salience(tick_results: {})
      expect(client.salience_map).to be(map_before)
    end

    it 'two clients have independent state' do
      client1 = described_class.new
      client2 = described_class.new
      client1.compute_salience(tick_results: { emotion: { arousal: 0.9 } })
      expect(client2.salience_map.history.size).to eq(0)
    end
  end
end
