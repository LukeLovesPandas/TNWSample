require 'securerandom'
require 'date'
require_relative '../repositories/item_price_history_source'


describe ItemPriceHistorySource do
  it 'initializes' do
    item_price_history_source = ItemPriceHistorySource.new
    expect(item_price_history_source.is_a?(ItemPriceHistorySource)).to be true
  end

  describe 'in memory database functionality' do
    it 'initializes with records' do
      item_price_history_source = ItemPriceHistorySource.new
      expect(item_price_history_source.all.length).to be > 0
    end

    it 'has multiple records with the same item_id' do
      item_price_history_entries = ItemPriceHistorySource.new.all
      all_item_ids = item_price_history_entries.collect(&:item_id)
      expect(all_item_ids.length).to be > all_item_ids.uniq.length
    end

    it 'can return multiple records with the same item_id' do
      source = ItemPriceHistorySource.new
      item_price_history_entries = source.all
      multi_entry_item_ids = item_price_history_entries.collect(&:item_id).uniq
      expect(source.get_item_entries(multi_entry_item_ids[0]).length).to be > 0
    end

    it 'returns latest entries first for multiple records' do
      source = ItemPriceHistorySource.new
      item_price_history_entries = source.all
      multi_entry_item_ids = item_price_history_entries.collect(&:item_id).uniq
      first_item_id_all_entries = source.get_item_entries(multi_entry_item_ids[0])
      expect(first_item_id_all_entries[0].entrydate).to be > first_item_id_all_entries[1].entrydate
    end

    it 'can add entries after instantiation' do
      source = ItemPriceHistorySource.new
      unique_item_id = SecureRandom.uuid
      source.add(unique_item_id, '3', DateTime.now)
      expect(source.all.last.item_id).to eq(unique_item_id)
    end

    it 'does not break sorting after adding an entry with different entrydate format' do
      source = ItemPriceHistorySource.new
      unique_item_id = SecureRandom.uuid
      original_count = source.get_item_entries(unique_item_id).length;
      source.add(unique_item_id, '3', "10/12/2019")
      expect(source.get_item_entries(unique_item_id).length).to be > original_count
    end
  end
end
