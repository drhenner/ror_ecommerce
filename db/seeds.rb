# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

puts "START SEEDING"

puts "COUNTRIES"
file_to_load  = Rails.root + 'db/seed/countries.yml'
countries_list   = YAML::load( File.open( file_to_load ) )

countries_list.each_pair do |key,country|
  s = Country.find_by(abbreviation: country['abbreviation'])
  unless s
    c = Country.create(country) unless s
    c.update_attribute(:active, true) if Country::ACTIVE_COUNTRY_IDS.include?(c.id)
  end
end

puts "States"
file_to_load  = Rails.root + 'db/seed/states.yml'
states_list   = YAML::load( File.open( file_to_load ) )


states_list.each_pair do |key,state|
  s = State.find_by(abbreviation: state['attributes']['abbreviation'], country_id: state['attributes']['country_id'])
  State.create(state['attributes']) unless s
end

puts "ROLES"
roles = Role::ROLES
roles.each do |role|
  Role.find_or_create_by(name: role)
end

puts "Address Types"
AddressType::NAMES.each do |address_type|
  AddressType.find_or_create_by(name: address_type)
end

puts "PHONE TYPES"
PhoneType::NAMES.each do |phone_type|
  PhoneType.find_or_create_by(name: phone_type)
end

puts "Item Types"
ItemType::NAMES.each do |item_type|
  ItemType.find_or_create_by(name: item_type)
end

puts "DEAL TYPES"
DealType::TYPES.each do |dt|
  DealType.find_or_create_by(name: dt)
end

puts "Accounts"
Account::TYPES.each_pair do |acc_type, value|
  acc = Account.find_by(name: acc_type)
  unless acc
    Account.create(:name => acc_type, :account_type => acc_type, :monthly_charge => value)
  end
end

puts "SHIPPING RATE TYPES"
ShippingRateType::TYPES.each do |rate_type|
  ShippingRateType.find_or_create_by(name: rate_type)
end

puts "Shipping Zones"
ShippingZone::LOCATIONS.each do |loc|
  ShippingZone.where(name: loc ).first_or_create
end

puts "ACCOUNT TYPES"
TransactionAccount::ACCOUNT_TYPES.each do |acc_type|
  TransactionAccount.where(name: acc_type ).first_or_create
end

puts "Return Reasons"
ReturnReason::REASONS.each do |value|
  rr = ReturnReason.find_by_label(value)
  unless rr
    ReturnReason.create(:label => value, :description => value )
  end
end

puts "Return CONDITIONS"
ReturnCondition::CONDITIONS.each do |value|
  rc = ReturnCondition.find_by(label: value)
  unless rc
    ReturnCondition.create(:label => value, :description => value )
  end
end
letters = Newsletter.count

puts "Newsletters"
Newsletter::AUTOSUBSCRIBED.each do |name|
  unless Newsletter.where(:name => name).first
    Newsletter.create(:name => name, :autosubscribe => true)
  end
end

if letters == 0
  # Subscribe everyone the first time around
  newsletter_ids = Newsletter.pluck(:id)
  User.find_each do |u|
    u.newsletter_ids = newsletter_ids
    u.save
  end
end

Newsletter::MANUALLY_SUBSCRIBE.each do |name|
  unless Newsletter.where(:name => name).first
    Newsletter.create(:name => name, :autosubscribe => false)
  end
end

puts "Referral Bonuses"
ReferralBonus::BONUSES.each do |referral_bonus_attributes|
  rb = ReferralBonus.find_by(name: referral_bonus_attributes[:name])
  unless rb
    ReferralBonus.create(referral_bonus_attributes)
  end
end

puts "Referral PROGRAMS"
ReferralProgram::PROGRAMS.each do |referral_program_attributes|
  rp = ReferralProgram.find_by(name: referral_program_attributes[:name])
  unless rp
    ReferralProgram.create(referral_program_attributes)
  end
end

puts "ReferralType"
ReferralType::NAMES.each do |name|
  ReferralType.find_or_create_by(name: name)
end
