require "rails_helper"

RSpec.describe "Merchant Invoices Show" do
  before :each do
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

  describe "display" do
    it "invoice attributes", :vcr do
      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content("Status: In Progress")
      expect(page).to have_content("Created On: #{@invoice_1.created_at.strftime("%A, %B %d, %Y")}")
      expect(page).to have_content(@invoice_1.customer.full_name)
      expect(page).to_not have_content(@invoice_1)
      expect(page).to_not have_content(@invoice_2)
    end

    it "Shows the total revenue for the selected invoice", :vcr do
      expect(@invoice_1.total_revenue).to eq(87600)
      expect(page).to have_content("Invoice Total Revenue: $876.00")
    end

    describe "invoice items" do
      it "lists all invoice item names, quantity, price and status", :vcr do
        within "#invoice_item-#{@invoice_item_2.id}" do
          expect(page).to have_content(@invoice_item_2.item.name)
          expect(page).to have_content(@invoice_item_2.quantity)
          expect(page).to have_content("$#{@invoice_item_2.unit_price.to_f/(100)}")
          expect(page).to have_content(@invoice_item_2.status)
          expect(page).to have_content(@item_1.name)
          expect(page).to_not have_content(@item_2)
        end

        visit merchant_invoice_path(@merchant_1, @invoice_2)
        within "#invoice_item-#{@invoice_item_5.id}" do
          expect(page).to have_content(@invoice_item_5.item.name)
          expect(page).to have_content(@invoice_item_5.quantity)
          expect(page).to have_content("$#{@invoice_item_5.unit_price.to_f/(100)}")
          expect(page).to have_content(@invoice_item_5.status)
          expect(page).to have_content(@item_3.name)
          expect(page).to_not have_content(@item_1)
        end
      end

      it "select update invoice item status", :vcr do
        visit merchant_invoice_path(@merchant_1, @invoice_1)
        within "#invoice_item-#{@invoice_item_2.id}" do
          expect(page).to have_content("Pending")
          select "Packaged"
          click_button "Update Invoice Item Status"

          expect(current_path).to eq(merchant_invoice_path(@merchant_1, @invoice_1))
          expect(@invoice_item_2.reload.status).to eq("Packaged")
        end
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
end
