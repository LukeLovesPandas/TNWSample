require_relative 'item_price_history_entry'

# Red Pencil Entry
class RedPencilEntry < ItemPriceHistoryEntry
  attr_accessor :expirationdate
  def initialize(id, item_id, price, entrydate, expirationdate)
    super(id, item_id, price, entrydate)
    @expirationdate = expirationdate
  end
end
