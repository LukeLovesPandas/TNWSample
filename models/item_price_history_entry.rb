# Model for ItemPriceHistory
class ItemPriceHistoryEntry
  attr_accessor :id, :item_id, :price, :entrydate
  def initialize(id, item_id, price, entrydate)
    @id = id
    @item_id = item_id
    @price = price
    @entrydate = entrydate
  end
end
