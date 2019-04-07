require 'active_support'
require 'active_support/core_ext/numeric/time'

# Generic Helper Methods
module Helpers
  def price_to_float(price)
    price.to_s.delete('$').delete(',').to_f
  end

  def get_percentage_float(numerator, denominator)
    (numerator.to_f - denominator.to_f) / numerator.to_f
  end

  def get_date_time(parseable_item)
    DateTime.parse(parseable_item.to_s)
  end
end
