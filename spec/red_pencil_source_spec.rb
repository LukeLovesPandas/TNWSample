require 'securerandom'
require 'date'
require_relative '../repositories/red_pencil_source'
require_relative '../models/red_pencil_entry'

describe RedPencilSource do

  it 'initializes' do
    source = RedPencilSource.new
    expect(source.is_a?(RedPencilSource)).to be true
  end

  describe 'in memory database functionality' do
    it 'initializes empty' do
      source = RedPencilSource.new
      expect(source.all.length).to be 0
    end

    it 'can add entries' do
      source = RedPencilSource.new
      uniq_item_id = SecureRandom.uuid
      source.add(RedPencilEntry.new(SecureRandom.uuid, uniq_item_id, "$12", DateTime.now, DateTime.now))
      expect(source.all.last.item_id).to eq(uniq_item_id)
      expect(source.all.last.expirationdate.nil?).to be true
    end

    it 'can retrieve all entries for an item_id' do
      source = RedPencilSource.new
      uniq_item_id = SecureRandom.uuid
      first_multi_entry = RedPencilEntry.new(SecureRandom.uuid, uniq_item_id, "$12", DateTime.now.strftime("%m/%d/%Y"), DateTime.now)
      second_multi_entry = RedPencilEntry.new(SecureRandom.uuid, uniq_item_id, "$10", DateTime.now - 30, DateTime.now)
      source.add(RedPencilEntry.new(SecureRandom.uuid, SecureRandom.uuid, "$2", DateTime.now - 10, DateTime.now))
      source.add(first_multi_entry)
      source.add(second_multi_entry)
      source.add(RedPencilEntry.new(SecureRandom.uuid, SecureRandom.uuid, "$18", DateTime.now - 20, DateTime.now))
      retrieved_items = source.get_item_entries(uniq_item_id)
      expect(retrieved_items[0].item_id).to eq(uniq_item_id)
      expect(retrieved_items[0].price).to eq(first_multi_entry.price)
      expect(retrieved_items[1].item_id).to eq(uniq_item_id)
      expect(retrieved_items[1].price).to eq(second_multi_entry.price)
    end

    it 'can update entries' do
      source = RedPencilSource.new
      uniq_item_id = SecureRandom.uuid
      theentry = RedPencilEntry.new(SecureRandom.uuid, uniq_item_id, '$12', DateTime.now, DateTime.now)
      source.add(theentry)
      added_entry_id = source.all.last.id
      update_entry = RedPencilEntry.new(added_entry_id, uniq_item_id, '$14', DateTime.now, DateTime.now)
      source.update(update_entry)
      update_entry.price = '$16'
      expect(source.all.last.id).to eq(added_entry_id)
      expect(source.all.last.price).to eq('$14')
      expect(source.all.last.expirationdate.to_date).to eq(update_entry.expirationdate.to_date)
    end
  end
end