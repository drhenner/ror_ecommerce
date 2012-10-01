# Read about factories at http://github.com/thoughtbot/factory_girl
#:type          => "CouponValue",
#:code          => "TEST COUPON",
#:amount        => "10.00",
#:minimum_value => "19.99",
#:percent       =>  nil,
#:description   =>  "Describe my coupon",
#:combine       =>  false
FactoryGirl.define do
  factory :coupon do
    type          "CouponValue"
    code          "TEST COUPON"
    amount        "10.00"
    minimum_value "19.99"
    percent     nil
    description "Describe my coupon"
    combine     false
    starts_at   "2011-01-08 19:39:58"
    expires_at  "2012-01-08 19:39:58"
  end

  factory :coupon_percent, class: "CouponPercent" do
    code          "TEST COUPON"
    amount        "10.00"
    minimum_value "19.99"
    percent     10
    description "Describe my coupon"
    combine     false
    starts_at   "2011-01-08 19:39:58"
    expires_at  "2012-01-08 19:39:58"
  end

  factory :coupon_value, class: "CouponValue" do
    code          "TEST COUPON"
    amount        "10.00"
    minimum_value "19.99"
    percent     nil
    description "Describe my coupon"
    combine     false
    starts_at   "2011-01-08 19:39:58"
    expires_at  "2012-01-08 19:39:58"
  end
  factory :coupon_one_time_percent, class: "CouponOneTimePercent" do
    percent 10.0
  end
  factory :coupon_one_time_value, class: "CouponOneTimeValue" do
  end
end# Read about factories at http://github.com/thoughtbot/factory_girl
