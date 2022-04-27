require "rails_helper"

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:unit_price) }
    it {
      should define_enum_for(:status).with([
        "Pending", "Packaged", "Shipped"
      ])
    }
  end

  describe "relationships" do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
    it { should have_one(:merchant).through(:item) }
    it { should have_many(:bulk_discounts).through(:merchant) }
  end

  describe "methods" do
    before do
      @merchant_1 = create :merchant
      @item_1 = create :item, {merchant_id: @merchant_1.id}
      @item_2 = create :item, {merchant_id: @merchant_1.id}
      @bulk_1 = @merchant_1.bulk_discounts.create!(percentage: 10, threshold: 10)
      @bulk_2 = @merchant_1.bulk_discounts.create!(percentage: 25, threshold: 15)
      @bulk_3 = @merchant_1.bulk_discounts.create!(percentage: 15, threshold: 20)

      @merchant_2 = create :merchant
      @item_3 = create :item, {merchant_id: @merchant_2.id}
      @item_4 = create :item, {merchant_id: @merchant_1.id}
      @bulk_4 = @merchant_2.bulk_discounts.create!(percentage: 10, threshold: 6)

      @customer = create(:customer)

      @invoice_1 = create(:invoice, customer_id: @customer.id)
      @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_4.id, quantity: 16, unit_price: 2200)
      @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 6, unit_price: 4200)
      @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 4, unit_price: 3500)
      @invoice_item_4 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 11, unit_price: 1200)

      @invoice_2 = create(:invoice, customer_id: @customer.id)
      @invoice_item_5 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 9, unit_price: 7300 )

      @invoice_3 = create(:invoice, customer_id: @customer.id)
      @invoice_item_6 = create(:invoice_item, invoice_id: @invoice_3.id, item_id: @item_2.id, quantity: 9, unit_price: 9500, status: 2)
    end

    it '#add_discount' do
      expect(@invoice_item_1.bulk_discounts).to eq([@bulk_1, @bulk_2, @bulk_3])
      expect(@invoice_item_1.add_discount).to eq(@bulk_2)
      expect(@invoice_item_5.bulk_discounts).to eq([@bulk_4])
      expect(@invoice_item_5.add_discount).to eq(@bulk_4)
      expect(@invoice_item_6.add_discount).to_not eq(@bulk_4)
    end

    it '#discount?' do
      expect(@invoice_item_1.discount?).to be true
      expect(@invoice_item_6.discount?).to be false
      expect(@invoice_item_1.discount?).to_not be false
    end
  end
end
