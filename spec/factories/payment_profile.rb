
Factory.define :payment_profile do |u|
  u.user            { |c| c.association(:user) }
  u.address         { |c| c.association(:address) }
  u.payment_cim_id  123456789
  u.default         true
  u.active          true
  u.cc_type         'visa'
  u.month           '05'
  u.year            '2013'
  u.last_digits     '3955'
  u.credit_card_info  { {
                          :number       => '4916477365453955',
                          :verification_value => '343',
                          :month        => '05',
                          :year         => '2013',
                          :first_name   => 'David',
                          :last_name    => 'Bowe',
                          :type         => 'visa'
                        }
                      }

end
