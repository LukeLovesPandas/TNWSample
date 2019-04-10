require_relative 'item_price_history_entry'

# Red Pencil Entry
class RedPencilEntry < ItemPriceHistoryEntry
  attr_accessor :expirationdate
  def initialize(id, item_id, price, entrydate, expirationdate)
    super(id, item_id, price, entrydate)
    @expirationdate = expirationdate
  end

  def to_hash
    hash_item = super
    hash_item[:expirationdate] = @expirationdate
    hash_item
  end
end
