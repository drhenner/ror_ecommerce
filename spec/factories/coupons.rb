# Read about factories at http://github.com/thoughtbot/factory_girl
#:type          => "CouponValue",
#:code          => "TEST COUPON",
#:amount        => "10.00",
#:minimum_value => "19.99",
#:percent       =>  nil,
#:description   =>  "Describe my coupon",
#:combine       =>  false
Factory.define :coupon do |f|
  f.type          "CouponValue"
  f.code          "TEST COUPON"
  f.amount        "10.00"
  f.minimum_value "19.99"
  f.percent     nil
  f.description "Describe my coupon"
  f.combine     false
  f.starts_at   "2011-01-08 19:39:58"
  f.expires_at  "2012-01-08 19:39:58"
end

Factory.define :coupon_percent do |f|
  f.type          "CouponPercent"
  f.code          "TEST COUPON"
  f.amount        "10.00"
  f.minimum_value "19.99"
  f.percent     10
  f.description "Describe my coupon"
  f.combine     false
  f.starts_at   "2011-01-08 19:39:58"
  f.expires_at  "2012-01-08 19:39:58"
end

Factory.define :coupon_value do |f|
  f.type          "CouponValue"
  f.code          "TEST COUPON"
  f.amount        "10.00"
  f.minimum_value "19.99"
  f.percent     nil
  f.description "Describe my coupon"
  f.combine     false
  f.starts_at   "2011-01-08 19:39:58"
  f.expires_at  "2012-01-08 19:39:58"
end# Read about factories at http://github.com/thoughtbot/factory_girl
