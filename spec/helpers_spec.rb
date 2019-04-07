require_relative '../modules/helpers'

class Testclass
  include Helpers
end

RSpec.describe Helpers do
  it "is initialized" do
    test = Testclass.new
    expect(test.is_a?(Testclass)).to be true
  end
end
