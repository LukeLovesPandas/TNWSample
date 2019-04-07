require 'active_support'
require 'active_support/core_ext/numeric/time'
require_relative '../modules/helpers'

class Testclass
  include Helpers
end

describe Helpers do
  test = Testclass.new
  it 'is initialized' do
    expect(test.is_a?(Testclass)).to be true
  end

  describe 'price_to_float' do
    it 'can handle dollar signs' do
      expect(test.price_to_float('$100.00')).to eq(100.0)
    end

    it 'can handle commas' do
      expect(test.price_to_float('$1,000.00')).to eq(1000.0)
    end

    it 'multiples of both' do
      expect(test.price_to_float('$$$1,000,000.00')).to eq(1000000.0)
    end

    it 'handles floats' do
      expect(test.price_to_float(1000.0)).to eq(1000.0)
    end

    it 'handles ints' do
      expect(test.price_to_float(100)).to eq(100.0)
    end
  end

  describe 'get_percentage_float' do
    it 'gets percentage float' do
      expect(test.get_percentage_float(100.0, 70.0)).to eq(0.30)
    end

    it 'handles ints' do
      expect(test.get_percentage_float(100, 70)).to eq(0.30)
    end
  end

  describe 'get_date_time' do
    it 'parses valid date strings' do
      expect(test.get_date_time('10/10/2019')).to eq(DateTime.parse('10/10/2019'))
    end

    it 'parses valid date time' do
      thedate = DateTime.parse('10/10/2019')
      expect(test.get_date_time(thedate)).to eq(thedate)
    end
  end
end
