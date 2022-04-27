class Invoice < ApplicationRecord
  validates :status, presence: true

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: {"Cancelled" => 0, "In Progress" => 1, "Completed" => 2}

  def total_revenue
    invoice_items.sum("quantity * unit_price")
  end

  def discount_revenue
    total_revenue - discount_amount
  end

  def self.incomplete_invoices
    joins(:invoice_items)
      .where(invoice_items: {status: [0, 1]})
      .group("invoices.id")
      .order(created_at: :asc)
  end

  def discount_amount
    invoice_items.joins(:bulk_discounts)
    .select("invoice_items.*, max(invoice_items.quantity * (invoice_items.unit_price * (bulk_discounts.percentage / 100.0))) as discount")
    .where("items.merchant_id = bulk_discounts.merchant_id")
    .where("invoice_items.quantity >= bulk_discounts.threshold")
    .group(:id)
    .sum(&:discount)
  end
end
