RSpec.describe BulkDiscount, type: :model do
  describe "validations" do
    it {should validate_numericality_of(:bulk_quantity).only_integer}
    it {should validate_numericality_of(:bulk_quantity).is_greater_than_or_equal_to(2)}
    it {should validate_numericality_of(:pc_off).is_greater_than_or_equal_to(0.01)}
    it {should validate_numericality_of(:pc_off).is_less_than_or_equal_to(99.99)}
  end

  describe "relationships" do
    it { should belong_to :user}
  end
end
