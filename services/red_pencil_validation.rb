require 'yaml'
require_relative '../modules/Helpers'
# Service for validating if redpencil is still valid
class RedPencilValidation
  include Helpers
  def initialize(latest_item_history, previous_item_history)
    @entry_configurables = YAML.safe_load(File.read(File.dirname(__FILE__) +
      '/../configurables/red_pencil.yaml'))['entry']
    @latest_item_history = latest_item_history
    @previous_item_history = previous_item_history
  end

  def within_discounted_price_range?
    latest_price_float = price_string_to_float(@latest_item_history.price)
    comparison_price_float = price_string_to_float(@previous_item_history.price)
    percentage = get_percentage_float(comparison_price_float, latest_price_float)
    @entry_configurables['minimum_reduction'] <= percentage &&
      percentage <= @entry_configurables['maximum_reduction']
  rescue StandardError => e
    p e
    false
  end
end
