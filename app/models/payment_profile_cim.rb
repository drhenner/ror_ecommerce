require 'active_merchant'
module PaymentProfileCim
  include ActiveMerchant::Billing

  def create
    if super and create_payment_profile
      # user.payment_profile_id = self.id  #  add this line if the user has a default payment_profile
      # user.save
      return true
    else
      if self.id
        #destroy the instance if it was created
        self.destroy
      end
      return false
    end
  end

  def update
    if super and update_payment_profile
      return true
    end
    return false
  end

  def destroy
    if delete_payment_profile and super
      return true
    end
    return false
  end

  private
  def create_payment_profile
    if not self.payment_cim_id
      return false
    end
    @gateway = CIM_GATEWAY

    @profile = {:customer_profile_id => self.user.customer_cim_id,
                :payment_profile => {:bill_to => self.address.try(:cc_params),
                                     :payment => {:credit_card => self.credit_card}
                                     }
                }
    response = @gateway.create_customer_payment_profile(@profile)
    if response.success? and response.params['customer_payment_profile_id']
      update_attributes({:payment_cim_id => response.params['customer_payment_profile_id']})
      self.credit_card = {}
      return true
    end
    self.errors.add(:base, 'Unable to save CreditCard try again or Please Call for help.')
    return false
  end

  def update_payment_profile
    @gateway = CIM_GATEWAY

    @profile = {:customer_profile_id => self.user.customer_cim_id,
                :payment_profile => {:customer_payment_profile_id => self.payment_cim_id,
                                     :bill_to => self.address.try(:cc_params),
                                     :payment => {:credit_card => self.credit_card}
                                     }
                }
    response = @gateway.update_customer_payment_profile(@profile)
    if response.success?
      self.credit_card = {}
      return true
    end
    self.errors.add(:base,'Unable to save CreditCard try again or Please Call for help.')
    return false
  end

  def delete_payment_profile
    @gateway = CIM_GATEWAY

    response = @gateway.delete_customer_payment_profile(:customer_profile_id => self.user.customer_cim_id,
                                                        :customer_payment_profile_id => self.payment_cim_id)
    if response.success?
      self.user.update_attributes({:payment_profile_id => nil})
      return true
    end
    return false
  end
end
