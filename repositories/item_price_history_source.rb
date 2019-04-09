require 'securerandom'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require_relative '../models/item_price_history_entry'

# ItemPriceHistory data source
class ItemPriceHistorySource
  def initialize
    connect
    populate
  end

  def connect
    @item_price_histories = []
  end

  def populate
    first_item_id = SecureRandom.uuid
    second_item_id = SecureRandom.uuid
    third_item_id = SecureRandom.uuid

    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, first_item_id, '$1440.00', DateTime.now - 135))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, first_item_id, '$75.00', DateTime.now - 35))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid, '$129.00', DateTime.now - 45))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, SecureRandom.uuid, '$450.00', DateTime.now - 22))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, second_item_id, '$1,000,000.00', DateTime.now - 42))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, second_item_id, '$1,010,000.00', DateTime.now - 1))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, third_item_id, '$500.00', DateTime.now - 70))
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, third_item_id, '$100.00', DateTime.now - 4))
  end

  def all
    @item_price_histories
  end

  def get_item_entries(item_id)
    @item_price_histories.select { |entry| entry.item_id == item_id }.sort { |entry_one, entry_two|  entry_two.entrydate <=> entry_one.entrydate }
  end

  def add(item_price_entry)
    @item_price_histories.push(ItemPriceHistoryEntry.new(SecureRandom.uuid, item_price_entry.item_id, item_price_entry.price, item_price_entry.entrydate))
  end
end
