class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.new(discount_params)
    if discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      redirect_to new_merchant_bulk_discount_path(@merchant)
      flash[:notice] = "Error: all requested areas must be filled!"
    end
  end

  def destroy
    @merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])
    discount.destroy

    redirect_to merchant_bulk_discounts_path(@merchant)
    flash[:notice] = "Discount has been removed."
  end

  private

  def discount_params
    params.permit(:id, :percentage, :threshold, :merchant_id)
  end

end