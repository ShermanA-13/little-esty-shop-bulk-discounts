require "rails_helper"

RSpec.describe "Admin Invoice Show", type: :feature do
  before :each do
    @merchant1 = create(:merchant)
    @items = create_list(:item, 4, merchant: @merchant1)
    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @invoice1 = create(:invoice, customer: @customer1)
    @invoice2 = create(:invoice, customer: @customer2)
    @invoice_item1 = create(:invoice_item, invoice: @invoice1, item: @items[0])
    @invoice_item2 = create(:invoice_item, invoice: @invoice1, item: @items[1])
    @invoice_item3 = create(:invoice_item, invoice: @invoice2, item: @items[2])
    @invoice_item4 = create(:invoice_item, invoice: @invoice2, item: @items[3])
  end

  it "Shows the attributes for the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    within("#invoice-info") do
      expect(page).to have_content(@invoice1.id)
      expect(page).to have_content(@invoice1.status)
      expect(page).to have_content(@invoice1.created_at.strftime("%A, %B %e, %Y"))
      expect(page).to have_content(@customer1.first_name)
      expect(page).to have_content(@customer1.last_name)
      expect(page).to_not have_content(@invoice2.id)
      expect(page).to_not have_content(@customer2.first_name)
      expect(page).to_not have_content(@customer2.last_name)
    end
  end

  it "Shows the attributes for the invoice items on the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    within("#invoice_items-#{@invoice_item1.id}") do
      expect(page).to have_content(@items.first.name)
      expect(page).to have_content(@invoice_item1.quantity)
      expect(page).to have_content(@invoice_item1.unit_price)
      expect(page).to have_content(@invoice_item1.status)
      expect(page).to_not have_content(@items.second.name)
    end

    within("#invoice_items-#{@invoice_item2.id}") do
      expect(page).to have_content(@items.second.name)
      expect(page).to have_content(@invoice_item2.quantity)
      expect(page).to have_content(@invoice_item2.unit_price)
      expect(page).to have_content(@invoice_item2.status)
      expect(page).to_not have_content(@items.first.name)
    end
  end

  it "Shows the total revenue for the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    expected = (@invoice_item1.quantity * @invoice_item1.unit_price) + (@invoice_item2.quantity * @invoice_item2.unit_price)

    expect(page).to have_content(@invoice1.total_revenue)
    expect(@invoice1.total_revenue).to eq(expected)
  end

  it "Updates the invoice status to the status that is selected from the status select field", :vcr do
    @invoice1.update(status: "In Progress")
    visit admin_invoice_path(@invoice1)

    within("#invoice-info") do
      expect(page).to have_content("In Progress")
    end

    select "Completed"
    click_button "Update Invoice Status"

    expect(current_path).to eq(admin_invoice_path(@invoice1))
    expect(@invoice1.reload.status).to eq("Completed")
  end

  describe 'discounts' do
    before do
      @merchant_1 = create :merchant
      @item_1 = create :item, {merchant_id: @merchant_1.id}
      @item_4 = create :item, {merchant_id: @merchant_1.id}
      @item_2 = create :item, {merchant_id: @merchant_1.id}
      @bulk_1 = @merchant_1.bulk_discounts.create!(percentage: 10, threshold: 10)
      @bulk_2 = @merchant_1.bulk_discounts.create!(percentage: 25, threshold: 15)
      @bulk_3 = @merchant_1.bulk_discounts.create!(percentage: 15, threshold: 20)

      @merchant_2 = create :merchant
      @item_3 = create :item, {merchant_id: @merchant_2.id}
      @bulk_4 = @merchant_2.bulk_discounts.create!(percentage: 10, threshold: 6)

      @customer = create(:customer)

      @invoice_1 = create(:invoice, customer_id: @customer.id)
      @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_4.id, quantity: 16, unit_price: 2200)
      @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 6, unit_price: 4200)
      @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 4, unit_price: 3500)
      @invoice_item_4 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 11, unit_price: 1200)

      @invoice_2 = create(:invoice, customer_id: @customer.id)
      @invoice_item_5 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 4, unit_price: 7300 )

      @invoice_3 = create(:invoice, customer_id: @customer.id)
      @invoice_item_6 = create(:invoice_item, invoice_id: @invoice_3.id, item_id: @item_2.id, quantity: 9, unit_price: 9500, status: 2)

      visit merchant_invoice_path(@merchant_1, @invoice_1)
    end

    it 'discount applied' do
      expect(page).to have_content("Invoice Total Revenue: $876.00")
      expect(page).to have_content("Invoice Total Revenue After Discount: $774.80")

      within "#invoice_item-#{@invoice_item_1.id}" do
        expect(page).to have_link("Discounts")
      end
    end

    it 'no discount applied' do
      visit merchant_invoice_path(@merchant_2, @invoice_2)

      expect(page).to have_content("Invoice Total Revenue: $292.00")
      expect(page).to_not have_content("Invoice Total Revenue After Discount: ")

      within "#invoice_item-#{@invoice_item_5.id}" do
        expect(page).to_not have_link("Discounts")
      end
    end
  end
end
