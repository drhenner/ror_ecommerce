require 'chronic'

module RorEReports
  class Sales
    def initialize(start_time, end_time)
      @start_time = start_time
      @end_time   = end_time
      @orders = Order.finished.between(start_time, end_time)
    end

    def weekly_summary
      [
        { date: '2013-03', amount: 20, sales: 4 },
        { date: '2013-04', amount: 10, sales: 2 },
        { date: '2013-05', amount: 5,  sales: 1 },
        { date: '2013-06', amount: 5,  sales: 2 },
        { date: '2013-07', amount: 20, sales: 5 }
      ]
    end
  end
end
