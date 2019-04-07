require 'securerandom'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'yaml'
require_relative '../models/item_price_history_entry'
require_relative '../services/red_pencil_validation'

describe RedPencilValidation do
  configurables = YAML.safe_load(File.read(File.dirname(__FILE__) +
     '/../configurables/red_pencil.yaml'))['entry']
  it 'is initialized' do
    test = RedPencilValidation.new(nil, nil)
    expect(test.is_a?(RedPencilValidation)).to be true
  end

  describe 'it validates price' do
    it 'has nils initialized' do
      validator = RedPencilValidation.new(nil, nil)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has invalid objects passed in' do
      validator = RedPencilValidation.new(1, 'test')
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories without prices set' do
      latest_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  nil, DateTime.now)
      previous_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  nil, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories without latest entry price set' do
      latest_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  nil, DateTime.now)
      previous_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  '$1,200.00', DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories without previous entry price set' do
      latest_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  '$1,200.00', DateTime.now)
      previous_entry = 
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  nil, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories that have lower than the minimum reduction needed' do
      lower_than_min_float = 1.00 - (configurables['minimum_reduction'] - 0.01)
      previous_price = 100
      latest_price = previous_price * lower_than_min_float;
      latest_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  latest_price, DateTime.now)
      previous_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  previous_price, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories that have higher than the minimum reduction needed' do
      higher_than_max_float = 1.00 - (configurables['maximum_reduction'] + 0.01)
      previous_price = 100
      latest_price = previous_price * higher_than_max_float;
      latest_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  latest_price, DateTime.now)
      previous_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  previous_price, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories that have higher than the minimum reduction needed' do
      higher_than_max_float = 1.00 - (configurables['maximum_reduction'] + 0.01)
      previous_price = 100
      latest_price = previous_price * higher_than_max_float;
      latest_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  latest_price, DateTime.now)
      previous_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  previous_price, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be false
    end

    it 'has ItemHistories that meet the requirements' do
      valid_float = 1.00 - (configurables['maximum_reduction'] - 0.01)
      previous_price = 100
      latest_price = previous_price * valid_float
      latest_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  latest_price, DateTime.now)
      previous_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                  previous_price, DateTime.now)
      validator = RedPencilValidation.new(latest_entry, previous_entry)
      expect(validator.within_discounted_price_range?).to be true
    end
  end
end
