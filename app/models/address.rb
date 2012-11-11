# == Schema Information
#
# Table name: addresses
#
#  id                :integer(4)      not null, primary key
#  address_type_id   :integer(4)
#  first_name        :string(255)
#  last_name         :string(255)
#  addressable_type  :string(255)     not null
#  addressable_id    :integer(4)      not null
#  address1          :string(255)     not null
#  address2          :string(255)
#  city              :string(255)     not null
#  state_id          :integer(4)
#  state_name        :string(255)
#  zip_code          :string(255)     not null
#  phone_id          :integer(4)
#  alternative_phone :string(255)
#  default           :boolean(1)      default(FALSE)
#  billing_default   :boolean(1)      default(FALSE)
#  active            :boolean(1)      default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#

class Address < ActiveRecord::Base
  belongs_to  :state
  belongs_to  :country
  belongs_to  :address_type
  belongs_to  :addressable, :polymorphic => true
  has_many     :phones, :as => :phoneable
  has_many     :shipments

  validates :first_name,  :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator },       :length => { :maximum => 25 }
  validates :last_name,   :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator },       :length => { :maximum => 25 }
  validates :address1,    :presence => true,       :length => { :maximum => 255 }
  validates :city,        :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator },       :length => { :maximum => 75 }
  #validates :state_id,       :presence => true,  :if => Proc.new { |address| Settings.have_state_in_address || address.country_id.blank?  }
  validates :state_id,      :presence => true,  :if => Proc.new { |address| Settings.require_state_in_address}
  validates :country_id,    :presence => true,  :if => Proc.new { |address| !Settings.require_state_in_address}
  #validates :state_name,  :presence => true,  :if => Proc.new { |address| address.state_id.blank?   }
  validates :zip_code,    :presence => true,       :length => { :maximum => 12 }
  #validates :phone_id,    :presence => true
  before_validation :sanitize_data

  #accepts_nested_attributes_for :phones

  # First and last name of the person on the address
  #
  # @example first_name == 'John', last_name == 'Doe'
  #    address.name  => 'John Doe'
  # @param none
  # @ return [String] first and last name on the address with a space between
  def name
    [first_name, last_name].compact.join(' ')
  end

  # Will inactivate and save the address
  #
  # @param none
  # @ return [Boolean] true or error(error will only happen if there is a bad record in the db)
  def inactive!
    self.active = false
    save!
  end

  # hash of all the address db attributes except created_at, updated_at, id
  #
  # @param none
  # @ return [Hash] address db attributes except created_at, updated_at, id
  def address_attributes
    attributes.delete_if {|key, value| ["id", 'updated_at', 'created_at'].any?{|k| k == key }}
  end

  # hash of all the address attributes to be passed to a creditcard processor
  #
  # @param none
  # @ return [Hash] address attributes for a creditcard processor
  def cc_params
    { :name     => name,
      :address1 => address1,
      :address2 => address2,
      :city     => city,
      :state    => state.abbreviation,
      :country  => state.country_id == Country::USA_ID ? 'US' : 'CAN',
      :zip      => zip_code#,
      #:phone    => phone
    }
  end

  # Method used to determine the shipping methods ids available for this address
  def shipping_method_ids
    if Settings.require_state_in_address
      state.shipping_zone.shipping_method_ids
    else
      country.shipping_zone_id ? country.shipping_zone.shipping_method_ids : []
    end
  end
  # Method used to determine the shipping_zone_id for this address
  #
  #  Specifically used to determine the order_item.shipping_rate_options
  def shipping_zone_id
    if Settings.require_state_in_address
      state.shipping_zone_id
    else
      country.shipping_zone_id
    end
  end

  # Use this method to update an address
  # => This method will create a new address object and make the address you are updating inactive
  # => If you always use this method for updating addresses you don't need to worry about old order
  # => referencing the wrong address
  #
  # @param none
  # @ return [Address] address of new address or of the old address with errors
  def self.update_address(old_address, params, address_type_id = AddressType::SHIPPING_ID )
    new_address = Address.new(params.merge( :address_type_id  => address_type_id,
                              :addressable_type => old_address.addressable_type,
                              :addressable_id   => old_address.addressable_id ))

    new_address.default = true if old_address.default
    if new_address.valid? && new_address.save_default_address(old_address.addressable, params)
      old_address.update_attributes(:active => false)
      new_address  ## return the new address without errors
    else
      old_address.update_attributes(params) ##  This should always fail
      old_address  ## return the old address with errors
    end
  end



  # Use this method to create an address
  # => This method will create a new address object and if the address is a default address it
  # => will make all other addresses that belong to the user non-default
  #
  # @param [object] object associated to the address (user or possibly a company in the future)
  # @param [Hash] hash of attributes for the new address
  # @ return [Boolean] true or nil
  def save_default_address(object, params)
    Address.transaction do
      if params[:default] && params[:default] != '0'
        Address.update_all( { :default  => false},
                            { :addresses => {
                                  :addressable_id => object.id,
                                  :addressable_type => object.class.to_s
                                            } }) if object
        self.default = true
      end
      if params[:billing_default] && params[:billing_default] != '0'
        Address.update_all( { :billing_default => false},
                            { :addresses => {
                                  :addressable_id => object.id,
                                  :addressable_type => object.class.to_s
                                            } }) if object
        self.billing_default = true
      end
      self.addressable = object
      self.save

    end
  end

  # Use this method to represent the full address as an array compacted
  #
  # @param [none]
  # @return [Array] Array has ("name", "address1", "address2"(unless nil), "city state zip")
  def full_address_array
    [name, address1, address2, city_state_zip].compact
  end

  # Use this method to represent the full address as an array compacted
  #
  # @param [Optional String] default is ', '
  # @return [String] address1 and address2 joined together with the string you pass in
  def address_lines(join_chars = ', ')
    [address1, address2].delete_if{|add| add.blank?}.join(join_chars)
  end

  # Use this method to represent the state abbreviation
  #  it is possible the state is nil. in that case the abbreviation will be stored in
  #  the state_name column in the DB
  #
  # @param [none]
  # @return [String] state abbreviation
  def state_abbr_name
    state ? state.abbreviation : state_name
  end

  # Use this method to represent the "city, state.abbreviation"
  #
  # @param [none]
  # @return [String] "city, state.abbreviation"
  def city_state_name
    [city, state_abbr_name].join(', ')
  end

  # Use this method to represent the "city, state.abbreviation zip_code"
  #
  # @param [none]
  # @return [String] "city, state.abbreviation zip_code"
  def city_state_zip
    [city_state_name, zip_code].join(' ')
  end

  private
    # This method is called to ensure data is formated without extra white space before_validation
    def sanitize_data
      self.first_name  = self.first_name.strip  unless self.first_name.blank?
      self.last_name   = self.last_name.strip   unless self.last_name.blank?
      self.city        = self.city.strip        unless self.city.blank?
      self.zip_code    = self.zip_code.strip    unless self.zip_code.blank?
      #self.phone      = self.phone.strip       unless self.phone.blank?
      self.address1    = self.address1.strip    unless self.address1.blank?
      self.address2    = self.address2.strip    unless self.address2.blank?
    end
end
