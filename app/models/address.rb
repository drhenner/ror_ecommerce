class Address < ActiveRecord::Base
  belongs_to  :state
  belongs_to  :address_type
  belongs_to  :addressable, :polymorphic => true
  has_many     :phones, :as => :phoneable
  has_many     :shipments

  validates :first_name,  :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator }
  validates :last_name,   :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator }
  validates :address1,    :presence => true
  validates :city,        :presence => true,
                          :format   => { :with => CustomValidators::Names.name_validator }
  validates :state_id,       :presence => true#,  :if => Proc.new { |address| address.state_name.blank?  }
  #validates :state_name,  :presence => true,  :if => Proc.new { |address| address.state_id.blank?   }
  validates :zip_code,    :presence => true
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

  def inactive!
    self.active = false
    save!
  end

  def address_attributes
    attributes.delete_if {|key, value| ["id", 'updated_at', 'created_at'].any?{|k| k == key }}
  end

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

  def full_address_array
    [name, address1, address2, city_state_zip].compact
  end

  def address_lines(join_chars = ', ')
    [address1, address2].delete_if{|add| add.blank?}.join(join_chars)
  end

  def state_abbr_name
    state ? state.abbreviation : state_name
  end

  def city_state_name
    [city, state_abbr_name].join(', ')
  end

  def city_state_zip
    [city_state_name, zip_code].join(' ')
  end

  def sanitize_data
    self.first_name  = self.first_name.strip  unless self.first_name.blank?
    self.last_name   = self.last_name.strip   unless self.last_name.blank?
    self.city       = self.city.strip       unless self.city.blank?
    self.zip_code    = self.zip_code.strip    unless self.zip_code.blank?
    #self.phone      = self.phone.strip      unless self.phone.blank?
    self.address1   = self.address1.strip   unless self.address1.blank?
    self.address2   = self.address2.strip   unless self.address2.blank?
  end
end
