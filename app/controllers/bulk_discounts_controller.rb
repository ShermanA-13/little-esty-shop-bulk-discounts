class BulkDiscountsController < ApplicationController
  before_action :find_merchant

  def index
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end

  def new
  end

  def create
    discount = BulkDiscount.new(discount_params)
    if discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      redirect_to new_merchant_bulk_discount_path(@merchant)
      flash[:notice] = "Error: all requested areas must be filled!"
    end
  end

  def edit
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    discount = BulkDiscount.find(params[:id])
    discount.update(discount_params)
    discount.save(discount_params)

    redirect_to merchant_bulk_discount_path(@merchant, discount)
    flash[:notice] = "Discount has been updated."
  end

  def destroy
    discount = BulkDiscount.find(params[:id])
    discount.destroy

    redirect_to merchant_bulk_discounts_path(@merchant)
    flash[:notice] = "Discount has been removed."
  end

  private

  def discount_params
    params.permit(:id, :percentage, :threshold, :merchant_id)
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

end