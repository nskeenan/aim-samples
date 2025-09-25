class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy

  validates_presence_of :guid,
                        :customer_email_address,
                        :customer_first_name,
                        :customer_last_name,
                        :customer_phone_number,
                        :customer_ship_address,
                        :customer_ship_city,
                        :customer_ship_state,
                        :customer_ship_zip, if: Proc.new { |o| o.status != 'pending' }

  before_validation :ensure_guid

  scope :carts, -> { where(status: "pending") }
  scope :incomplete, -> { where(status: ["submitted", 'pay-pal-started']) }
  scope :paid, -> { where(status: "paid") }
  scope :shipped, -> { where(status: "shipped") }
  scope :complete_noship, -> { where(status: "closed-noship") }

  serialize :gateway_response

  def pay_pal_express_payment
    @pay_pal_express_payment ||= PayPalExpressPayment.new(order: self, token: self.pp_token)
  end

  def confirm_and_process_payment

    payment = self.pay_pal_express_payment
    pay_info = payment.complete_payment

    puts "pay_infopay_infopay_infopay_infopay_info"
    puts pay_info.to_yaml

    if pay_info
      self.pp_token = nil
      self.status = 'paid'
      self.gateway_response = pay_info
      self.confirmation = pay_info["PAYMENTINFO_0_TRANSACTIONID"]
      self.paid_at = Time.now
      return self.save
    end

    false
  end

  def save_with_pay_pal_express_payment
    if self.total > 0
      self.status = 'pay-pal-started'
      self.pp_token = self.pay_pal_express_payment.token
    end
    self.save
  end

  def tax_state
    customer_billing_state
  end

  def tax_state=(val)
    self.customer_billing_state = val
  end

  def ensure_guid
    self.guid = SecureRandom.hex unless self.guid
  end

  def add(product)
    raise "Invalid product. #{product.class} is not a BookProduct." unless product.is_a?( BookProduct )
    self.order_items.inspect
    item = self.order_items.where(book_product: product).first
    item ||= self.order_items.build({
      book_product: product
    })

    item.price_per_item = product.price
    item.quantity += 1

    if item.save
      self.touch
    end

    Rails.logger.debug "item.inspect"
    Rails.logger.debug item.inspect
  end

  def subtotal
    total = 0.0
    self.order_items.each do |item|
      total += item.subtotal
    end
    total
  end

  def shipping_cost
    ship_total = 0.0
    self.order_items.each do |item|
      ship_total += item.shipping_cost
    end
    ship_total
  end

  def sales_tax
    return 0.0 unless tax_state.to_s.upcase == "FL"
    tax_total = BigDecimal.new('0.0')
    tax_rate = BigDecimal.new('0.07')
    self.order_items.each do |item|
      tax_total += item.sales_tax_subtotal
    end
    tax_total.to_f
  end

  def total_pretax
    0.0 + subtotal + shipping_cost
  end

  def total
    total_pretax + sales_tax
  end

  def total_cents
    (total * 100).to_i
  end

  def total_paid_to_gateway
    total_cents
  end
end
