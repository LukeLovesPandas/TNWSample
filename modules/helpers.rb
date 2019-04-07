require 'active_support'
require 'active_support/core_ext/numeric/time'

# Generic Helper Methods
module Helpers
  def price_string_to_float(price_string)
    price_string.to_s.sub('$', '').sub(',', '').to_f
  end

  def get_percentage_float(numerator, denominator)
    (numerator - denominator) / numerator
  end

  def get_date_time(date_string)
    DateTime.parse(date_string)
  rescue StandardError
    potential_string
  end
end
