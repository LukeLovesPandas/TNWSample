require 'securerandom'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require_relative '../models/red_pencil_entry'
require_relative '../modules/helpers'
class RedPencilSource
  include Helpers
  def initialize
    connect
  end

  def connect
    @red_pencil_entries = []
  end

  def all
    @red_pencil_entries
  end

  def get_item_entries(item_id)
    @red_pencil_entries.select { |entry| entry.item_id == item_id }.sort { |entry_one, entry_two|  get_date_time(entry_two.entrydate) <=> get_date_time(entry_one.entrydate) }
  end

  def add(red_pencil_entry)
    @red_pencil_entries.push(RedPencilEntry.new(SecureRandom.uuid, red_pencil_entry.item_id, red_pencil_entry.price, get_date_time(red_pencil_entry.entrydate), nil))
  end

  def update(red_pencil_entry)
    entry = @red_pencil_entries.select { | entry | entry.id == red_pencil_entry.id }.first
    entry.item_id = red_pencil_entry.item_id
    entry.price = red_pencil_entry.price
    entry.entrydate = red_pencil_entry.entrydate ? get_date_time(red_pencil_entry.entrydate) : nil
    entry.expirationdate = red_pencil_entry.expirationdate ? get_date_time(red_pencil_entry.expirationdate) : nil
  end
end