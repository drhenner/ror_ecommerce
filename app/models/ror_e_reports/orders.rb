require 'chronic'

module RorEReports
  class Orders
    def initialize(start__time, end__time)
      @start_time = start__time
      @end_time   = end__time
      @legders = Order.where("created_at >= ? AND created_at <= ?", start_time, end_time)
    end

    def finished_order_ids
      @order_ids ||= Order.finished.where("created_at >= ? AND created_at <= ?", start_time, end_time).pluck(:id)
    end

    def quantity
      @quantity ||= finished_order_ids.size
    end

    def taxes_collected
      @taxes_collected  ||= (Invoice.where("created_at >= ? AND created_at <= ?", start_time, end_time).where({:invoices => {:state => 'paid'}}).sum(:tax_amount)).to_f / 100.0
    end

    def total_amount
      @total_amount     ||= Invoice.where("created_at >= ? AND created_at <= ?", start_time, end_time).where({:invoices => {:state => 'paid'}}).sum(:amount).round_at(2)
    end

    def taxes_returned
      @taxes_returned   ||= (ReturnAuthorization.where("created_at >= ? AND created_at <= ?", start_time, end_time).where({:return_authorizations => {:state => 'complete'}}).sum(:tax_amount)).to_f / 100.0
    end

    def amount_returned
      @amount_returned  ||= ReturnAuthorization.where("created_at >= ? AND created_at <= ?", start_time, end_time).where({:return_authorizations => {:state => 'complete'}}).sum(:amount).round_at(2)
    end

    def start_time
      @start_time
    end

    def end_time
      @end_time
    end

  end
end
