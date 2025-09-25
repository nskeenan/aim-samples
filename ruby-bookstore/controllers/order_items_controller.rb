class OrderItemsController < ApplicationController
  skip_before_action :require_login, only: [:update]
  
  def update
    cart = current_order
    if cart
      order_item = cart.order_items.where(id: params[:id]).first
      
      if order_item
        quantity = order_item_params[:quantity]
        unless quantity =~ /[^0-9]/
          quantity = quantity.to_i
          
          if quantity > 0
            order_item.update_attributes(order_item_params)
            flash[:notice] = "Your cart items have been updated"
          else
            title = order_item.book_product.book.title
            subtitle = order_item.book_product.display_name
            order_item.destroy
            flash[:notice] = "#{title} (#{subtitle}) has been removed from your cart."
          end
          
        end
        redirect_to cart_path
      end
      
      
    else
      redirect_to root_path
    end
  end
  
  private
    def order_item_params
      params.require(:order_item).permit(:quantity)
    end
end