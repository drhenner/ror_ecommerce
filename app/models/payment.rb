# == Schema Information
#
# Table name: payments
#
#  id              :integer(4)      not null, primary key
#  invoice_id      :integer(4)
#  confirmation_id :string(255)
#  amount          :integer(4)
#  error           :string(255)
#  error_code      :string(255)
#  message         :string(255)
#  action          :string(255)
#  params          :text
#  success         :boolean(1)
#  test            :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#

class Payment < ApplicationRecord
  belongs_to :invoice

  serialize :params
  # this is initialized to an instance of ActiveMerchant::Billing::Base.gateway
  #cattr_accessor :gateway

  validates :amount,      presence: true
  validates :invoice_id,  presence: true


#  ActiveMerchant::Billing::AuthorizeNetCimGateway
#  METHOD: create_customer_profile_transaction(options)
#
#   Creates a new payment transaction from an existing customer profile
#
#   This is what is used to charge a customer whose information you have stored in a Customer Profile.
#
#   Returns a Response object that contains the result of the transaction in params[‘direct_response’]
#   Options
#
#       * :transaction — A hash containing information on the transaction that is being requested. (REQUIRED)
#
#   Transaction
#
#       * :type — The type of transaction. Can be either :auth_only, :capture_only, or :auth_capture. (REQUIRED)
#       * :amount — The amount for the tranaction. Formatted with a decimal. For example "4.95" (REQUIRED)
#       * :customer_profile_id — The Customer Profile ID of the customer to use in this transaction. (REQUIRED)
#       * :customer_payment_profile_id — The Customer Payment Profile ID of the Customer Payment Profile to use in this transaction. (REQUIRED)




  def capture_cim
    @gateway = GATEWAY

    response = @gateway.create_customer_profile_transaction({:transaction => {
                           :type                        => :auth_capture,
                           :amount                      => self.invoice.amount.to_s,
                           :customer_profile_id         => self.invoice.order.user.customer_cim_id,
                           :customer_payment_profile_id => self.invoice.order.user.payment_profile.payment_cim_id}})

    if response.success? and response.authorization
      update_attributes({:confirmation_id => response.authorization})
      return true
    else
      update_attributes({:error => !response.success?,
                         :error_code => response.params['messages']['message']['code'],
                         :error_message => response.params['messages']['message']['text']})
      return false
    end
  end


  class << self

      def store( credit_card, options = {})
        options[:order_id] ||= unique_order_number
        process( 'store' ) do |gw|
          gw.store( credit_card, options )
        end
      end

      def unstore( profile_key, options = {})
        options[:order_id] ||= unique_order_number
        process( 'unstore' ) do |gw|
          gw.unstore( profile_key, options )
        end
      end

      def authorize(amount, credit_card, options = {})
        process('authorization', amount) do |gw|
          gw.authorize(amount, credit_card, options)
        end
      end

      def capture(amount, authorization, options = {})
        process('capture', amount) do |gw|
          gw.capture(amount, authorization, options)
        end
      end

      def charge( amount, profile_key, options ={})
        options[:order_id] ||= unique_order_number
        if GATEWAY.respond_to?(:purchase)
          process( 'charge', amount ) do |gw|
            gw.purchase( amount, profile_key, options )
          end
        else
          # do it in 2 transactions
          process( 'charge', amount ) do |gw|
            result = gw.authorize( amount, profile_key, options )
            if result.success?
              gw.capture( amount, result.reference, options )
            else
              result
            end
          end
        end
      end

      # validate card via transaction
      def validate_card( credit_card, options ={})
        options[:order_id] ||= unique_order_number
        # authorize $1
        amount = 100
        result = process( 'validate', amount ) do |gw|
          gw.authorize( amount, credit_card, options )
        end
        if result.success?
          # void it
          result = process( 'validate' ) do |gw|
            gw.void( result.reference, options )
          end
        end
        result
      end

    private

      def unique_order_number
        "#{Time.now.to_i}-#{rand(1_000_000)}"
      end

      def process(action, amount = nil)
        result = Payment.new
        result.amount = (amount && !amount.integer?) ? (amount * 100).to_i : amount
        result.action = action
          begin
            response          = yield GATEWAY
            result.success    = response.success?
            result.confirmation_id  = response.authorization
            result.message    = response.message
            result.params     = response.params
            result.test       = response.test?
          rescue ActiveMerchant::ActiveMerchantError => e
            #puts e
            result.success = false
            result.confirmation_id = nil
            result.message = e.message
            result.params = {}
            result.test = GATEWAY.test?
          end
        result
      end
  end
end
