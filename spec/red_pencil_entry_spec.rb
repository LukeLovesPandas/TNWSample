require 'securerandom'
require_relative '../models/red_pencil_entry'

describe RedPencilEntry do
  it 'initializes' do
    source = RedPencilEntry.new(nil, nil, nil, nil, nil)
    expect(source.is_a?(RedPencilEntry)).to be true
  end

  it 'converts to hash' do 
    item_id = SecureRandom.uuid
    price = 1
    entrydate = DateTime.now
    expirationdate = DateTime.now
    source = RedPencilEntry.new(SecureRandom.uuid, item_id, price, entrydate, expirationdate)
    actual = source.to_hash
    expect(actual).to eq({'item_id': item_id, 'price': price, 'entrydate': entrydate, 'expirationdate': expirationdate})
  end
end
