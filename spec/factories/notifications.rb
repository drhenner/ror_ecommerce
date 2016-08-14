FactoryGirl.define do
  factory :notification do
    user       { |c| c.association(:user) }
    type       "OutOfStockNotification"
    notifiable { |c| c.association(:variant) }
    send_at    "2016-08-13 13:25:58"
    sent_at    nil
  end

  factory :low_stock_notification do
    user       { |c| c.association(:user) }
    type       "LowStockNotification"
    notifiable { |c| c.association(:variant) }
    send_at    "2016-08-13 13:25:58"
    sent_at    nil
  end

  factory :out_of_stock_notification do
    user       { |c| c.association(:user) }
    type       "OutOfStockNotification"
    notifiable { |c| c.association(:variant) }
    send_at    "2016-08-13 13:25:58"
    sent_at    nil
  end

  factory :in_stock_notification do
    user       { |c| c.association(:user) }
    type       "InStockNotification"
    notifiable { |c| c.association(:variant) }
    send_at    "2016-08-13 13:25:58"
    sent_at    nil
  end
end
