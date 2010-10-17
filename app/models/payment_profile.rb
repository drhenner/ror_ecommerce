class PaymentProfile < ActiveRecord::Base
  include ActiveMerchant::Utils
  
  belongs_to :user
  belongs_to :address
  
  #attr_accessor :address
  #attr_accessor :credit_card
  attr_accessor       :request_ip, :credit_card
  
  before_create :create_payment_profile
  
  validates :user_id,         :presence => true
  validates :payment_cim_id,  :presence => true
  #validates :address_id,      :presence => true
  
  def create_payment_profile
    if self.payment_cim_id
      return false
    end
    @gateway = get_payment_gateway
  
    @profile = {:customer_profile_id  => self.user.get_cim_profile,
                :payment_profile      => {:bill_to => self.address,
                                          :payment => {:credit_card => CreditCard.new(self.credit_card)}
                                         }
                }
    response = @gateway.create_customer_payment_profile(@profile)
    if response.success? and response.params['customer_payment_profile_id']
      update_attributes({:payment_cim_id => response.params['customer_payment_profile_id']})
      self.credit_card = {} # clear the credit_card info from memory (for security)
      return true
    end
    #return false
    self.errors.add_to_base('Unable to save CreditCard try again or Please Call for help.')
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  validate            :validate_card  
  before_save         :store_card
  before_destroy      :unstore_card
  
  #attr_accessible # none
  
  # ------------
  state_machine :state, :initial => :no_info do
    before_transition any => :no_info,   :do => :unstore_card

    event :authorized do 
      transition any => :authorized
    end
    event :error do
      transition any => :error
    end
    event :remove do
      from = any - [:no_info]
      transition from => :no_info
    end
  end
  
  # ------------
  # behave like it's 
  #   has_one :credit_card 
  #   accepts_nested_attributes_for :credit_card
   
  def credit_card=( card_or_params )
    @credit_card = case card_or_params
      when ActiveMerchant::Billing::CreditCard, nil
        card_or_params
      else
        ActiveMerchant::Billing::CreditCard.new(card_or_params)
      end
  end
  
  def new_credit_card
    # populate new card with some saved values
    ActiveMerchant::Billing::CreditCard.new(
      :first_name  => card_first_name,
      :last_name   => card_last_name,
      # :address etc too if we have it
      :type        => card_type
    )
  end
  
  # -------------
  # move this into a test helper...
  def self.example_credit_card_params( params = {})
    default = { 
      :first_name         => 'First Name', 
      :last_name          => 'Last Name', 
      :type               => 'visa',
      :number             => '4111111111111111', 
      :month              => '10', 
      :year               => '2012', 
      :verification_value => '999' 
    }.merge( params )
    
    specific = case gateway_name #SubscriptionConfig.gateway_name
      when 'authorize_net_cim'
        { 
          :type               => 'visa',
          :number             => '4007000000027', 
        }
        # 370000000000002 American Express Test Card
        # 6011000000000012 Discover Test Card
        # 4007000000027 Visa Test Card
        # 4012888818888 second Visa Test Card
        # 3088000000000017 JCB 
        # 38000000000006 Diners Club/ Carte Blanche
        
      when 'bogus'
        { 
          :type               => 'bogus',
          :number             => '1', 
        }   
        
      else
        {}     
      end
      
    default.merge(specific).merge(params)
  end
  
  # -------------
  private
  
  # validate :validate_card
  def validate_card
    #debugger
    return if credit_card.nil?
    # first validate via ActiveMerchant local code
    unless credit_card.valid?
      # collect credit card error messages into the profile object
      #errors.add(:credit_card, "must be valid") 
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
      return
    end
    
    if SubscriptionConfig.validate_via_transaction
      transaction do # makes this atomic
        tx = Payment.validate_card( credit_card )
        subscription.transactions.push( tx )
        if ! tx.success?
          #errors.add(:credit_card, "failed to #{tx.action} card: #{tx.message}")
          errors.add_to_base "Failed to #{tx.action} card: #{tx.message}"
          return
        end
      end
    end
    true
  end
  
  def store_card
    #debugger
    return unless credit_card && credit_card.valid?
    
    transaction do # makes this atomic
      if profile_key
        tx  = Payment.update( profile_key, credit_card)
      else
        tx  = Payment.store(credit_card)
      end
      subscription.transactions.push( tx )    
      if tx.success?
        # remember the token/key/billing id (whatever)
        self.profile_key = tx.token
    
        # remember some non-secure params for convenience
        self.card_first_name     = credit_card.first_name
        self.card_last_name      = credit_card.last_name
        self.card_type           = credit_card.type
        self.card_display_number = credit_card.display_number
        self.card_expires_on     = credit_card.expiry_date.expiration.to_date
    
        # clear the card in memory
        self.credit_card = nil
    
        # change profile state
        self.state = 'authorized' # can't call authorized! here, it saves
        
      else # ! tx.success
        #errors.add(:credit_card, "failed to #{tx.action} card: #{tx.message}")
        errors.add_to_base "Failed to #{tx.action} card: #{tx.message}"
      end
      
      tx.success
    end
  end
  
  def unstore_card
    return if no_info? || profile_key.nil?
    transaction do # atomic
      tx  = Payment.unstore( profile_key )
      subscription.transactions.push( tx )
      if tx.success?
        # clear everything in case this is ever called without destroy 
        self.profile_key         = nil
        self.card_first_name     = nil
        self.card_last_name      = nil
        self.card_type           = nil
        self.card_display_number = nil
        self.card_expires_on     = nil
        self.credit_card         = nil
       # change profile state
        self.state               = 'no_info' # can't call no_info! here, it saves
      else
        #errors.add(:credit_card, "failed to #{tx.action} card: #{tx.message}")
        errors.add_to_base "Failed to #{tx.action} card: #{tx.message}"
      end
      tx.success
    end
  end
  
  
  
  
end
