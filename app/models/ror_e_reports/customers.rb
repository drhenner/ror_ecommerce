require 'chronic'
module RorEReports
  class Customers
    def initialize(start__time, end__time)
      @start_time = start__time
      @end_time   = end__time
    end

    def total_users
      @total_users ||= User.where("users.created_at <= ?", end_time).count
    end

    def users_in_timeframe
      @users_in_timeframe ||= User.where("users.created_at >= ? AND users.created_at <= ?", start_time, end_time).count
    end

    def total_customers
      @total_customers  ||= Order.finished.where("orders.completed_at <= ?", end_time).group(:user_id).count.size
    end

    def customers_in_timeframe
      @customers_in_timeframe   ||= Order.finished.where(["orders.completed_at >= ? AND orders.completed_at <= ?",start_time,end_time]).group(:user_id).count.size
    end

    def start_time
      @start_time
    end

    def end_time
      @end_time
    end

  end
end
