class CartController < ApplicationController
  skip_before_action :require_login, only: [:index, :add, :edit, :update, :show, :download, :cancel, :pp_confirm]

  def add
    product = BookProduct.where(id: params[:id]).first
    if product
      cart = current_order_or_new
      cart.add(product)

      title = product.book.title
      subtitle = product.display_name
      flash[:notice] = "#{title} (#{subtitle}) has been added to your cart."
    else
      flash[:error] = "The product you attempted to add could not be found."
    end
    redirect_to cart_path
  end

  def index
    unless has_cart? && current_order.order_items.size > 0
      flash[:error] = "You have not added any items to your cart."
      redirect_to root_path
      return
    end

    @cart = current_order
    @cart.update(pp_token: nil)
  end

  def edit
    unless has_cart? && current_order.order_items.size > 0
      flash[:error] = "You have not added any items to your cart."
      redirect_to root_path
      return
    end

    unless tax_state_param.blank?
      current_order.tax_state = tax_state_param
      current_order.save
    end

    if current_order.tax_state.blank?
      flash.now[:error] = "You have not selected your billing state"
      @cart = current_order
      render :index
      return
    end

    @cart = current_order
    @cart.update(pp_token: nil)
  end

  def update
    if has_cart? && current_order.order_items.size > 0
      @cart = current_order

      @cart.attributes = order_attributes

      if @cart.valid? && @cart.save_with_pay_pal_express_payment
        Rails.logger.debug @cart.pay_pal_express_payment.inspect
        pp_payment = @cart.pay_pal_express_payment

        next_url = pp_payment.checkout_url
        if ! next_url
          flash[:error] = "PayPal is unable to process your transaction at this time. Please try your order again later or contact us for assistance."
          next_url = cart_path
        end
        redirect_to next_url
      else
        flash.now[:error] = @cart.errors.full_messages # + @payment.errors.full_messages
        render :edit
      end

    else
      redirect_to root_path
    end
  end

  def show
    @cart = Order.find_by_guid(params[:guid])
    unless @cart
      redirect_to "/bookstore/"
    end
  end

  def download
    cart = Order.find_by_guid(params[:guid])
    book_product = BookProduct.find_by_id(params[:product_id])
    check_item = nil
    check_item = cart.order_items.where(book_product_id: book_product.id).first if cart && book_product
    if check_item
      send_file book_product.downloadable_file.current_path
    else
      flash[:error] = "No downloadable product found"
      redirect_to "/bookstore/"
    end
  end

  def cancel
    flash[:error] = "Your payment has been canceled. You can edit your order and restart the checkout process."
    @cart = current_order
    redirect_to cart_path
  end

  def pp_confirm
    token = params[:token]
    @order = Order.where("pp_token = ?", token).first
    if @order && @order.confirm_and_process_payment
      flash[:notice] = "Your payment has been confirmed and your order has been processed."
      remove_order_from_session
      OrderMailer.order_complete_confirmation(@order).deliver_later
      OrderMailer.admin_order_notification(@order).deliver_later
      redirect_to order_complete_path(@order.guid)
    else
      flash[:error] = "Your payment could not be confirmed. Please contact us if you are experiencing payment issues."
      redirect_to cart_path
    end
  end

  private

    def payment_params
      params.require(:order_payment)
            .permit(:cc_first_name,
                    :cc_last_name,
                    :cc_num,
                    :cc_exp_month,
                    :cc_exp_year,
                    :cc_cvv,
                    :billing_address,
                    :billing_city,
                    :billing_state,
                    :billing_zip)
    end

    def order_attributes
      params.require(:order)
            .permit(:customer_email_address,
                    :customer_phone_number,
                    :customer_first_name,
                    :customer_last_name,
                    :customer_ship_address,
                    :customer_ship_city,
                    :customer_ship_state,
                    :customer_ship_zip)
    end

    def tax_state_param
      return nil unless params[:order]
      params[:order][:tax_state]
    end

end
