require 'securerandom'
require_relative '../models/item_price_history_entry'

describe ItemPriceHistoryEntry do
  it 'initializes' do
    source = ItemPriceHistoryEntry.new(nil, nil, nil, nil)
    expect(source.is_a?(ItemPriceHistoryEntry)).to be true
  end

  it 'converts to hash' do 
    item_id = SecureRandom.uuid
    price = 1
    entrydate = DateTime.now
    source = ItemPriceHistoryEntry.new(SecureRandom.uuid, item_id, price, entrydate)
    actual = source.to_hash
    expect(actual).to eq({'item_id': item_id, 'price': price, 'entrydate': entrydate})
  end
end