class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :book_product

  def subtotal
    self.quantity ||= 0
    self.price_per_item ||= self.book_product.price if self.book_product
    self.price_per_item ||= 0
    self.price_per_item * self.quantity
  end

  def shipping_cost
    self.quantity ||= 0
    return 0 unless self.book_product
    ship_cost = self.book_product.shipping_charge
    ship_cost ||= 0.0
    ship_cost * self.quantity
  end

  def sales_tax
    return BigDecimal.new('0.0') unless order && order.tax_state.to_s.upcase == "FL"
    tax_rate = BigDecimal.new('0.07')
    (price_per_item * tax_rate).round(2, :up)
  end

  def sales_tax_subtotal
    self.quantity * sales_tax
  end
end
