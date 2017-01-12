## Inventory is a table that needs to have pestimistic locking.
#  This requires the SQL to be very fast in order to ensure the table is not locked.
#  Please keep the table free from extra data that might cause locking to become an issue.


# == Schema Information
#
# Table name: inventories
#
#  id                          :integer          not null, primary key
#  count_on_hand               :integer          default(0)
#  count_pending_to_customer   :integer          default(0)
#  count_pending_from_supplier :integer          default(0)
#

class Inventory < ApplicationRecord
  has_one :variant
  has_many :accounting_adjustments, as: :adjustable

  validate :must_have_stock

  # with SQL math add to count_on_hand attribute
  #
  # @param [Integer] number of variants to add
  # @return [none]
  def add_count_on_hand(num)
    ### don't lock if we have plenty of stock.
    begining_stock_status = stock_status
    if low_stock? && num.to_i < 0
      lock!
        self.count_on_hand = count_on_hand + num.to_i
      save!
    else
      self.count_on_hand = count_on_hand + num.to_i
      sql = "UPDATE inventories SET count_on_hand = (#{num} + count_on_hand) WHERE id = #{self.id}"
      ActiveRecord::Base.connection.execute(sql)
    end
    send_stock_notifications(num) if begining_stock_status != stock_status
  end

  # returns quantity available in stock
  #
  # @param [none]
  # @return [Boolean]
  def quantity_available
    (count_on_hand - count_pending_to_customer)
  end

  # returns quantity available to purchase
  #
  # @param [none]
  # @return [Boolean]
  def quantity_purchaseable(admin_purchase = false)
    admin_purchase ? (quantity_available - Variant::ADMIN_OUT_OF_STOCK_QTY) : (quantity_available - Variant::OUT_OF_STOCK_QTY)
  end

  def quantity_purchaseable_if_user_wants(this_number_of_items, admin_purchase = false)
    (quantity_purchaseable(admin_purchase) < this_number_of_items) ? quantity_purchaseable(admin_purchase) : this_number_of_items
  end

  # returns true if the stock level is above or == the out of stock level
  #
  # @param [none]
  # @return [Boolean]
  def sold_out?
    (quantity_available) <= Variant::OUT_OF_STOCK_QTY
  end

  # returns true if the stock level is above or == the low stock level
  #
  # @param [none]
  # @return [Boolean]
  def low_stock?
    (quantity_available) <= Variant::LOW_STOCK_QTY
  end

  def stock_status
    return "sold_out"  if sold_out?
    return "low_stock" if low_stock?
    "available"
  end

  # returns "(Sold Out)" or "(Low Stock)" or "" depending on if the variant is out of stock / low stock or has enough stock.
  #
  # @param [Optional String]
  # @param [Optional String]
  # @return [String]
  def display_stock_status(start = '(', finish = ')')
    return "#{start}Sold Out#{finish}"  if sold_out?
    return "#{start}Low Stock#{finish}" if low_stock?
    ''
  end

  private

  def send_stock_notifications(num)
    if num.to_i < 0 # added_stock
      if sold_out?
        OutOfStockNotification.send!(variant.id)
      elsif low_stock?
        LowStockNotification.send!(variant.id)
      end
    elsif !sold_out?
      InStockNotification.send!(variant.id)
    end
  end

  def must_have_stock
    if (count_on_hand - count_pending_to_customer) < 0
      errors.add :count_on_hand, 'There is not enough stock to sell this item'
    end
  end
end
