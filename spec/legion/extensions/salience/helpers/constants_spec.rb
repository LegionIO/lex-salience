# frozen_string_literal: true

RSpec.describe Legion::Extensions::Salience::Helpers::Constants do
  describe 'SALIENCE_SOURCES' do
    it 'defines exactly 8 sources' do
      expect(described_class::SALIENCE_SOURCES.size).to eq(8)
    end

    it 'includes all expected sources' do
      %i[emotion mood attention curiosity homeostasis trust empathy volition].each do |source|
        expect(described_class::SALIENCE_SOURCES).to include(source)
      end
    end

    it 'is frozen' do
      expect(described_class::SALIENCE_SOURCES).to be_frozen
    end
  end

  describe 'SOURCE_WEIGHTS' do
    it 'has a weight for every source' do
      described_class::SALIENCE_SOURCES.each do |source|
        expect(described_class::SOURCE_WEIGHTS).to have_key(source)
      end
    end

    it 'weights sum to 1.0' do
      total = described_class::SOURCE_WEIGHTS.values.sum
      expect(total).to be_within(0.001).of(1.0)
    end

    it 'assigns emotion the highest weight' do
      expect(described_class::SOURCE_WEIGHTS[:emotion]).to eq(0.20)
    end

    it 'is frozen' do
      expect(described_class::SOURCE_WEIGHTS).to be_frozen
    end
  end

  describe 'URGENCY_LEVELS' do
    it 'defines exactly 5 levels' do
      expect(described_class::URGENCY_LEVELS.size).to eq(5)
    end

    it 'includes critical, high, moderate, low, background' do
      %i[critical high moderate low background].each do |level|
        expect(described_class::URGENCY_LEVELS).to include(level)
      end
    end

    it 'is frozen' do
      expect(described_class::URGENCY_LEVELS).to be_frozen
    end
  end

  describe 'URGENCY_THRESHOLDS' do
    it 'has a threshold for every urgency level' do
      described_class::URGENCY_LEVELS.each do |level|
        expect(described_class::URGENCY_THRESHOLDS).to have_key(level)
      end
    end

    it 'covers the full range from 0 to 1' do
      thresholds = described_class::URGENCY_THRESHOLDS.values
      expect(thresholds.min).to eq(0.0)
      expect(thresholds.max).to eq(0.9)
    end

    it 'sets critical at 0.9' do
      expect(described_class::URGENCY_THRESHOLDS[:critical]).to eq(0.9)
    end

    it 'sets background at 0.0' do
      expect(described_class::URGENCY_THRESHOLDS[:background]).to eq(0.0)
    end
  end

  describe 'numeric constants' do
    it 'defines MAX_SALIENCE_ITEMS as 10' do
      expect(described_class::MAX_SALIENCE_ITEMS).to eq(10)
    end

    it 'defines SALIENCE_DECAY_RATE as 0.05' do
      expect(described_class::SALIENCE_DECAY_RATE).to eq(0.05)
    end

    it 'defines INTEGRATION_ALPHA as 0.3' do
      expect(described_class::INTEGRATION_ALPHA).to eq(0.3)
    end

    it 'defines NOVELTY_BOOST as 0.2' do
      expect(described_class::NOVELTY_BOOST).to eq(0.2)
    end

    it 'defines CONFLICT_AMPLIFIER as 1.5' do
      expect(described_class::CONFLICT_AMPLIFIER).to eq(1.5)
    end
  end
end
