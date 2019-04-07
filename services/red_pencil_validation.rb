require 'yaml'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require_relative '../modules/Helpers'
# Service for validating if redpencil is still valid
class RedPencilValidation
  include Helpers
  def initialize(latest_item_history, previous_item_history, previous_red_pencil)
    @entry_configurables = YAML.safe_load(File.read(File.dirname(__FILE__) +
      '/../configurables/red_pencil.yaml'))['entry']
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

  def for_the_same_item?
    has_both_entries = !@latest_item_history.nil? && !@latest_item_history.item_id.nil? &&  !@previous_item_history.nil? && !@previous_item_history.item_id.nil?
    item_history_ids_same = has_both_entries && @latest_item_history.item_id == @previous_item_history.item_id
    item_history_ids_same && (@previous_red_pencil.nil? || @previous_red_pencil.item_id ==  @latest_item_history.item_id)
  end

  def has_stable_date?
    get_date_time(@latest_item_history.entrydate) >= (get_date_time(@previous_item_history.entrydate) + @entry_configurables['stabilization_days'])
  rescue StandardError
    false
  end

  def should_add_red_pencil?
    for_the_same_item? && within_discounted_price_range? && has_stable_date?
  end

  def enough_time_since_last_red_pencil?
    (@previous_red_pencil.nil? || DateTime.now >=
      (get_date_time(@previous_red_pencil.expirationdate) +
      @entry_configurables['stabilization_days']))
  rescue StandardError
    false
  end

  def eligible_for_new_red_pencil?
    enough_time_since_last_red_pencil? && should_add_red_pencil?
  end

end
