require 'rails_helper'

describe 'merchant bulk discount index page' do
  before do
    @merchant_1 = create(:merchant)
    @item = create :item, {merchant_id: @merchant_1.id}

    @customer_1 = create(:customer)
    @invoice_1 = create(:invoice, customer_id: @customer_1.id)
    @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 27,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "346785678",
      invoice_id: @invoice_1.id,
      result: 0
    )

    @customer_2 = create(:customer)
    @invoice_2 = create(:invoice, customer_id: @customer_2.id)
    @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 12,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "223385678",
      invoice_id: @invoice_2.id,
      result: 0
    )

    @customer_3 = create(:customer)
    @invoice_3 = create(:invoice, customer_id: @customer_3.id)
    @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_3.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 44,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "12343785678",
      invoice_id: @invoice_3.id,
      result: 0
    )

    @customer_4 = create(:customer)
    @invoice_4 = create(:invoice, customer_id: @customer_4.id)
    @invoice_item_4 = create(:invoice_item, invoice_id: @invoice_4.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 52,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "5436723678",
      invoice_id: @invoice_4.id,
      result: 0
    )

    @customer_5 = create(:customer)
    @invoice_5 = create(:invoice, customer_id: @customer_5.id)
    @invoice_item_5 = create(:invoice_item, invoice_id: @invoice_5.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 65,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "512385678",
      invoice_id: @invoice_5.id,
      result: 0
    )

    @customer_6 = create(:customer)
    @invoice_6 = create(:invoice, customer_id: @customer_6.id)
    @invoice_item_6 = create(:invoice_item, invoice_id: @invoice_6.id, item_id: @item.id)
    @transactions_list_1 = create_list(
      :transaction, 23,
      credit_card_expiration_date: "0 Seconds From Now",
      credit_card_number: "56785234",
      invoice_id: @invoice_6.id,
      result: 0
    )

    @bulk_1 = @merchant_1.bulk_discounts.create!(percentage: 5, threshold: 10)
    @bulk_2 = @merchant_1.bulk_discounts.create!(percentage: 10, threshold: 15)
    @bulk_3 = @merchant_1.bulk_discounts.create!(percentage: 15, threshold: 20)
    @bulk_4 = @merchant_1.bulk_discounts.create!(percentage: 20, threshold: 25)

    visit merchant_bulk_discount_path(@merchant_1, @bulk_1)
  end

  it 'has discount and threshold' do
    expect(page).to have_content("Percentage: #{@bulk_1.percentage}")
    expect(page).to have_content("Threshold: #{@bulk_1.threshold}")
  end
end