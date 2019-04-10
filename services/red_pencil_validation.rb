require 'yaml'
require 'securerandom'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require_relative '../modules/Helpers'

# Service for validating if redpencil is still valid
class RedPencilValidation
  include Helpers
  def initialize(latest_item_history, previous_item_history, previous_red_pencil)
    configurables = YAML.safe_load(File.read(File.dirname(__FILE__) +
    '/../configurables/red_pencil.yaml'))
    @entry_configurables = configurables['entry']
    @expiration_configurables = configurables['expiration']
    @latest_item_history = latest_item_history
    @previous_item_history = previous_item_history
    @previous_red_pencil = previous_red_pencil
  end

  def within_discounted_price_range?
    latest_price_float = price_to_float(@latest_item_history.price)
    previous_price_float = price_to_float(@previous_item_history.price)
    percentage_change = get_percentage_float(previous_price_float, latest_price_float)
    @entry_configurables['minimum_reduction'] <= percentage_change &&
      percentage_change <= @entry_configurables['maximum_reduction']
  rescue StandardError
    false
  end

  def both_item_entries_exist
    !@latest_item_history.nil? && !@latest_item_history.item_id.nil? &&
      !@previous_item_history.nil? && !@previous_item_history.item_id.nil?
  end

  def for_the_same_item?
    item_history_ids_same = both_item_entries_exist &&
                            @latest_item_history.item_id ==
                            @previous_item_history.item_id
    item_history_ids_same && (@previous_red_pencil.nil? ||
      @previous_red_pencil.item_id == @latest_item_history.item_id)
  end

  def stable_date?
    get_date_time(@latest_item_history.entrydate) >=
      (get_date_time(@previous_item_history.entrydate) +
      @entry_configurables['stabilization_days'])
  rescue StandardError
    false
  end

  def should_add_red_pencil?
    for_the_same_item? && within_discounted_price_range? && stable_date?
  end

  def enough_time_since_last_red_pencil?
    (@previous_red_pencil.nil? || @previous_red_pencil.expirationdate.nil? || DateTime.now >=
      (get_date_time(@previous_red_pencil.expirationdate) +
      @entry_configurables['stabilization_days']))
  end

  def eligible_for_new_red_pencil?
    enough_time_since_last_red_pencil? && should_add_red_pencil?
  end

  def new_red_pencil
    RedPencilEntry.new(SecureRandom.uuid, @latest_item_history.item_id,
                       @previous_item_history.price,
                       @latest_item_history.entrydate, nil)
  end

  def not_expired?
    @previous_red_pencil.nil? || !@previous_red_pencil.nil? &&
      @previous_red_pencil.expirationdate.nil?
  end

  def exists_and_active?
    !@previous_red_pencil.nil? && not_expired?
  end

  def calculated_expiration_date
    (get_date_time(@previous_red_pencil.entrydate) +
      @expiration_configurables['duration_of_red_pencil'])
  end

  def gone_past_duration?
    DateTime.now > calculated_expiration_date
  end

  def price_difference_invalid?
    latest_price_float = price_to_float(@latest_item_history.price)
    red_pencil_price_float = price_to_float(@previous_red_pencil.price)
    percentage_change = get_percentage_float(red_pencil_price_float,
                                             latest_price_float)
    percentage_change > @expiration_configurables['maximum_reduction'] ||
      percentage_change < 0
  end

  def should_be_expired?
    not_expired? && (gone_past_duration? || price_difference_invalid?)
  end

  def expired_red_pencil
    expirationdate = calculated_expiration_date if gone_past_duration?
    expirationdate = @latest_item_history.entrydate if price_difference_invalid?
    RedPencilEntry.new(@previous_red_pencil.id, @previous_red_pencil.item_id,
                       @previous_red_pencil.price,
                       @previous_red_pencil.entrydate, expirationdate)
  end
end
