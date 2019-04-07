require_relative '../services/red_pencil_validation'

RSpec.describe RedPencilValidation do
    it "is initialized" do
      test = RedPencilValidation.new
      expect(test.is_a?(RedPencilValidation)).to be true
    end
  end