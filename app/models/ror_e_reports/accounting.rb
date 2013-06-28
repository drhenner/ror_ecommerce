require 'chronic'
module RorEReports
  class Accounting
    def initialize(start_time, end_time)
      @start_time = start_time
      @end_time   = end_time
      @legders = TransactionLedger.where("created_at >= ? AND created_at <= ?", start_time, end_time).to_a
    end

    def revenue
      @legders.sum(&:revenue)
    end

    def cash
      @legders.sum(&:cash)
    end

    def accounts_receivable
      @legders.sum(&:accounts_receivable)
    end

    def accounts_payable
      @legders.sum(&:accounts_payable)
    end

    def start_time
      @start_time
    end

    def end_time
      @end_time
    end

    def self.daily(date = Date.today - 1.day)
      [date.beginning_of_day, date.end_of_day]
    end

    def self.weekly(week_of = 'last week')
      report_week = Chronic.parse(week_of)
      [report_week.beginning_of_week, report_week.end_of_week]
    end
  end
end
