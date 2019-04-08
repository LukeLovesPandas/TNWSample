require 'securerandom'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'yaml'
require_relative '../models/item_price_history_entry'
require_relative '../models/red_pencil_entry'
require_relative '../services/red_pencil_validation'

describe RedPencilValidation do
  same_item_id = SecureRandom.uuid
  configurables = YAML.safe_load(File.read(File.dirname(__FILE__) +
     '/../configurables/red_pencil.yaml'))
  entry_configurables = configurables['entry']
  expiration_configurables = configurables['expiration']
  it 'is initialized' do
    test = RedPencilValidation.new(nil, nil, nil)
    expect(test.is_a?(RedPencilValidation)).to be true
  end

  describe 'valid for new red pencil' do
    describe 'it validates the entries are for the same item' do
      it 'has nils' do
        validator = RedPencilValidation.new(nil, nil, nil)
        expect(validator.for_the_same_item?).to be false
      end

      it 'has mismatched item_ids and no red pencil' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                    nil, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.for_the_same_item?).to be false
      end

      it 'has same item_ids and no red pencil' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.for_the_same_item?).to be true
      end

      it 'has same item_ids and mismatched red pencil' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        red_pencil = RedPencilEntry.new(SecureRandom.uuid, SecureRandom.uuid,
                                        nil, nil, nil)
        validator = RedPencilValidation.new(latest_entry, previous_entry,
                                            red_pencil)
        expect(validator.for_the_same_item?).to be false
      end

      it 'has same item_ids and red pencil with the same item_id' do
        latest_entry = 
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry = 
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        red_pencil = RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil,
                                        nil, nil)
        validator = RedPencilValidation.new(latest_entry, previous_entry,
                                            red_pencil)
        expect(validator.for_the_same_item?).to be true
      end
    end

    describe 'it validates price' do
      it 'has nils initialized' do
        validator = RedPencilValidation.new(nil, nil, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has invalid objects passed in' do
        validator = RedPencilValidation.new(1, 'test', nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has ItemHistories without prices set' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has ItemHistories without latest entry price set' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    '$1,200.00', DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has ItemHistories without previous entry price set' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    '$1,200.00', DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has item entries that have lower than the minimum reduction needed' do
        lower_than_min_float = 1.00 -
                               (entry_configurables['minimum_reduction'] - 0.01)
        previous_price = 100
        latest_price = previous_price * lower_than_min_float
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has item entries that have higher than the minimum reduction needed' do
        higher_than_max_float = 1.00 -
                                (entry_configurables['maximum_reduction'] + 0.01)
        previous_price = 100
        latest_price = previous_price * higher_than_max_float;
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has item entries that have higher than the minimum reduction needed' do
        higher_than_max_float = 1.00 -
                                (entry_configurables['maximum_reduction'] + 0.01)
        previous_price = 100
        latest_price = previous_price * higher_than_max_float;
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be false
      end

      it 'has item entries that meet the requirements' do
        valid_float = 1.00 - (entry_configurables['maximum_reduction'] - 0.01)
        previous_price = 100
        latest_price = previous_price * valid_float
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.within_discounted_price_range?).to be true
      end
    end

    describe 'it validates stability' do
      it 'has nils initialized for previous date' do
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, nil)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, nil)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.stable_date?).to be false
      end

      it 'has a date less then the stability maximum' do
        one_day_less_than_acceptable =
          DateTime.now - (entry_configurables['stabilization_days'] - 1)
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, one_day_less_than_acceptable)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.stable_date?).to be false
      end

      it 'has a date equal to the required stability' do
        exact_acceptable_date = DateTime.now -
                                (entry_configurables['stabilization_days'])
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, exact_acceptable_date)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.stable_date?).to be true
      end

      it 'has a date greater than the required stability' do
        more_than_acceptable_date = 
          DateTime.now - (entry_configurables['stabilization_days'] + 1)
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    nil, more_than_acceptable_date)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.stable_date?).to be true
      end
    end

    describe 'it validates if enough time has passed since last red pencil' do
      it 'has all nils' do
        validator = RedPencilValidation.new(nil, nil, nil)
        expect(validator.enough_time_since_last_red_pencil?).to be true
      end

      it 'the last red pencil entry is less than the allowable entry period' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now -
                             (entry_configurables['stabilization_days'] - 1))
        validator = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validator.enough_time_since_last_red_pencil?).to be false
      end

      it 'the last red pencil entry is within the allowable new entry period' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now -
                             (entry_configurables['stabilization_days']))
        validator = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validator.enough_time_since_last_red_pencil?).to be true
      end

      it 'the last red pencil entry is exceeds new entry period' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now -
                             (entry_configurables['stabilization_days'] + 1))
        validator = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validator.enough_time_since_last_red_pencil?).to be true
      end
    end

    describe 'it validates ability to add' do
      it 'has nils' do
        validator = RedPencilValidation.new(nil, nil, nil)
        expect(validator.should_add_red_pencil?).to be false
      end

      it 'has a valid price reduction but invalid stability' do
        valid_float = 1.00 - (entry_configurables['maximum_reduction'] - 0.01)
        previous_price = 100
        latest_price = previous_price * valid_float
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, DateTime.now)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.should_add_red_pencil?).to be false
      end

      it 'has a valid price stability but invalid price reduction' do
        more_than_acceptable_date =
          DateTime.now - (entry_configurables['stabilization_days'] + 1)
        invalid_float = 1.00 - (entry_configurables['maximum_reduction'] + 0.01)
        previous_price = 100
        latest_price = previous_price * invalid_float
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, more_than_acceptable_date)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.should_add_red_pencil?).to be false
      end

      it 'has both valid price stability and price reduction' do
        more_than_acceptable_date =
          DateTime.now - (entry_configurables['stabilization_days'] + 1)
        valid_float = 1.00 - (entry_configurables['maximum_reduction'] - 0.01)
        previous_price = 100
        latest_price = previous_price * valid_float
        latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, more_than_acceptable_date)
        validator = RedPencilValidation.new(latest_entry, previous_entry, nil)
        expect(validator.should_add_red_pencil?).to be true
      end
    end

    describe 'it validates if it is eligible for a new red pencil' do
      more_than_acceptable_date =
        DateTime.now - (entry_configurables['stabilization_days'] + 1)
      valid_float = 1.00 - (entry_configurables['maximum_reduction'] - 0.01)
      previous_price = 100
      latest_price = previous_price * valid_float
      valid_latest_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                  latest_price, DateTime.now)
      valid_previous_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                  previous_price, more_than_acceptable_date)
      it 'has all nils' do
        validator = RedPencilValidation.new(nil, nil, nil)
        expect(validator.eligible_for_new_red_pencil?).to be false
      end

      it 'can add and the last red pencil entry is nil' do
        validator = 
          RedPencilValidation.new(valid_latest_entry, valid_previous_entry, nil)
        expect(validator.eligible_for_new_red_pencil?).to be true
      end

      it 'cannot add and the last red pencil is nil' do
        invalid_float = 1.00 - (entry_configurables['maximum_reduction'] + 0.01)
        invalid_latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price * invalid_float, DateTime.now)
        validator =
          RedPencilValidation.new(invalid_latest_entry, valid_previous_entry,
                                  nil)
        expect(validator.eligible_for_new_red_pencil?).to be false
      end

      it 'can add and enough time has passed since last red pencil ' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now - 
                             (entry_configurables['stabilization_days']))
        validator = 
          RedPencilValidation.new(valid_latest_entry, valid_previous_entry,
                                  red_pencil_entry)
        expect(validator.eligible_for_new_red_pencil?).to be true
      end

      it 'can add and not enough time has passed since last red pencil ' do
        red_pencil_entry = 
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now - 
                             (entry_configurables['stabilization_days'] - 1))
        validator = 
          RedPencilValidation.new(valid_latest_entry, valid_previous_entry,
                                  red_pencil_entry)
        expect(validator.eligible_for_new_red_pencil?).to be false
      end
    end

    describe 'it can return a new red pencil entry' do
      it 'returns a red pencil entry' do
        more_than_acceptable_date = 
          DateTime.now - (entry_configurables['stabilization_days'] + 1)
        valid_float = 1.00 - (entry_configurables['maximum_reduction'] - 0.01)
        previous_price = 100
        latest_price = previous_price * valid_float
        valid_latest_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price, DateTime.now)
        valid_previous_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    previous_price, more_than_acceptable_date)
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now -
                             (entry_configurables['stabilization_days']))
        validator = 
          RedPencilValidation.new(valid_latest_entry, valid_previous_entry,
                                  red_pencil_entry)
        new_red_pencil = validator.new_red_pencil
        expect(new_red_pencil.id.nil?).to be false
        expect(new_red_pencil.item_id).to eq(valid_latest_entry.item_id)
        expect(new_red_pencil.price).to eq(valid_previous_entry.price)
        expect(new_red_pencil.entrydate).to eq(valid_latest_entry.entrydate)
        expect(new_red_pencil.expirationdate).to eq(nil)
      end
    end
  end

  describe 'should be expired' do
    describe 'checks if it is already expired' do
      it 'is not expired if it doesn\'t exist' do
        validation = RedPencilValidation.new(nil, nil, nil)
        expect(validation.not_expired?).to be true
      end

      it 'is not expired if entry has no expiration date' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             nil)
        validation = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validation.not_expired?).to be true
      end

      it 'is expired if there is an expiration date' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, DateTime.now,
                             DateTime.now)
        validation = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validation.not_expired?).to be false
      end
    end

    describe 'calculates expiration date' do
      it 'gets an expiration based on configuration' do
        entrydate = DateTime.now
        expected_expiration = entrydate +
                              expiration_configurables['duration_of_red_pencil']
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, entrydate,
                             nil)
        validation = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validation.calculated_expiration_date.to_date)
          .to eq(expected_expiration.to_date)
      end
    end

    describe 'checks if the current red pen is past expiration date' do
      it 'is not past expiration if calculated expiration is after now' do
        entrydate = DateTime.now
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, entrydate,
                             nil)
        validation = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validation.gone_past_duration?).to be false
      end

      it 'is past expiration if calculated expiration is before now' do
        entrydate =
          DateTime.now -
          (expiration_configurables['duration_of_red_pencil'] + 1)
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, entrydate,
                             nil)
        validation = RedPencilValidation.new(nil, nil, red_pencil_entry)
        expect(validation.gone_past_duration?).to be true
      end
    end

    describe 'checks if the price has changed outside of allowable range' do
      it 'is invalid if the price has increased' do
        latest_price_entry = 
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    101, DateTime.now)

        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, 100,
                             DateTime.now, nil)
        validation = 
          RedPencilValidation.new(latest_price_entry, nil, red_pencil_entry)
        expect(validation.price_difference_invalid?).to be true
      end

      it 'is invalid if the price has decreased beyond the maximum' do
        red_pencil_price = 100
        latest_price_reduction =
          red_pencil_price * (1.0 -
                             (expiration_configurables['maximum_reduction'] +
                             0.01))
        latest_price_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price_reduction, DateTime.now)

        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, red_pencil_price,
                             DateTime.now, nil)
        validation = RedPencilValidation.new(latest_price_entry, nil,
                                             red_pencil_entry)
        expect(validation.price_difference_invalid?).to be true
      end

      it 'is valid if price has decreased but not beyond the maximum' do
        red_pencil_price = 100
        latest_price_reduction =
          red_pencil_price * (1.0 -
                             (expiration_configurables['maximum_reduction'] -
                             0.01))
        latest_price_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    latest_price_reduction, DateTime.now)

        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, red_pencil_price,
                             DateTime.now, nil)
        validation = 
          RedPencilValidation.new(latest_price_entry, nil, red_pencil_entry)
        expect(validation.price_difference_invalid?).to be false
      end
    end

    describe 'checks if it should be expired' do
      red_pencil_price = 100
      latest_price_reduction =
        red_pencil_price * (1.0 -
                           (expiration_configurables['maximum_reduction'] -
                            0.01))
      valid_latest_price_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                  latest_price_reduction, DateTime.now)
      it 'should not be expired if it is already expired' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, nil, nil,
                             DateTime.now)
        validation =
          RedPencilValidation.new(valid_latest_price_entry, nil,
                                  red_pencil_entry)
        expect(validation.should_be_expired?).to be false
      end

      it 'should not if no expiration and within the duration and price range' do
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id,
                             red_pencil_price, DateTime.now, nil)
        validation = 
          RedPencilValidation.new(valid_latest_price_entry, nil,
                                  red_pencil_entry)
        expect(validation.should_be_expired?).to be false
      end

      it 'should if is not expired and outside of duration' do
        entrydate =
          DateTime.now -
          (expiration_configurables['duration_of_red_pencil'] +
           1)
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, red_pencil_price,
                             entrydate, nil)
        validation =
          RedPencilValidation.new(valid_latest_price_entry, nil,
                                  red_pencil_entry)
        expect(validation.should_be_expired?).to be true
      end

      it 'should if it is not expired and price change is invalid' do
        entrydate =
          DateTime.now -
          (expiration_configurables['duration_of_red_pencil'] +
           1)
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, red_pencil_price,
                             entrydate, nil)
        invalid_latest_price_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    red_pencil_price + 1, DateTime.now)
        validation =
          RedPencilValidation.new(invalid_latest_price_entry, nil,
                                  red_pencil_entry)
        expect(validation.should_be_expired?).to be true
      end
    end

    describe 'gets expired red pencil object' do
      red_pencil_price = 100
      latest_price_reduction =
        red_pencil_price * (1.0 -
                           (expiration_configurables['maximum_reduction'] -
                           0.01))
      valid_latest_price_entry =
        ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                  latest_price_reduction, DateTime.now)
      it 'gets an expiration of entrydate plus redpen duration' do
        entrydate =
          DateTime.now -
          (expiration_configurables['duration_of_red_pencil'] +
          1)
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id,
                             red_pencil_price, entrydate, nil)
        validation =
          RedPencilValidation.new(valid_latest_price_entry, nil,
                                  red_pencil_entry)
        expired_red_pencil = validation.expired_red_pencil
        expect(expired_red_pencil.id).to eq(red_pencil_entry.id)
        expect(expired_red_pencil.item_id).to eq(red_pencil_entry.item_id)
        expect(expired_red_pencil.price).to eq(red_pencil_entry.price)
        expect(expired_red_pencil.entrydate.to_date)
          .to eq(red_pencil_entry.entrydate.to_date)
        expect(expired_red_pencil.expirationdate.to_date)
          .to eq((DateTime.now - 1).to_date)
      end

      it 'expiration date is latest item entry date if price range invalid' do
        entrydate =
          DateTime.now -
          (expiration_configurables['duration_of_red_pencil'] +
           1)
        latest_price_entry_date = DateTime.now
        red_pencil_entry =
          RedPencilEntry.new(SecureRandom.uuid, same_item_id, red_pencil_price,
                             entrydate, nil)
        invalid_latest_price_entry =
          ItemPriceHistoryEntry.new(SecureRandom.uuid, same_item_id,
                                    red_pencil_price + 1,
                                    latest_price_entry_date)
        validation =
          RedPencilValidation.new(invalid_latest_price_entry, nil,
                                  red_pencil_entry)
        expired_red_pencil = validation.expired_red_pencil
        expect(expired_red_pencil.id).to eq(red_pencil_entry.id)
        expect(expired_red_pencil.item_id).to eq(red_pencil_entry.item_id)
        expect(expired_red_pencil.price).to eq(red_pencil_entry.price)
        expect(expired_red_pencil.entrydate).to eq(red_pencil_entry.entrydate)
        expect(expired_red_pencil.expirationdate).to eq(latest_price_entry_date)
      end

      it 'gets no expiration if previous conditions not met' do
        red_pencil_entry = 
          RedPencilEntry.new(SecureRandom.uuid, same_item_id,
                             red_pencil_price, DateTime.now, nil)
        validation =
          RedPencilValidation.new(valid_latest_price_entry, nil,
                                  red_pencil_entry)
        expired_red_pencil = validation.expired_red_pencil
        expect(expired_red_pencil.id).to eq(red_pencil_entry.id)
        expect(expired_red_pencil.item_id).to eq(red_pencil_entry.item_id)
        expect(expired_red_pencil.price).to eq(red_pencil_entry.price)
        expect(expired_red_pencil.entrydate).to eq(red_pencil_entry.entrydate)
        expect(expired_red_pencil.expirationdate).to eq(nil)
      end
    end
  end
end
