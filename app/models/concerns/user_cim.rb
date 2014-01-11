require 'active_merchant'
module UserCim
  extend ActiveSupport::Concern

  # place holder method for creating cim profiles for recurring billing
  #
  # @param  [ none ]
  # @return [ String ] CIM id returned from the gateway
  def get_cim_profile
    return customer_cim_id if customer_cim_id
    create_cim_profile
    customer_cim_id
  end
  # UNCOMMENT if you are using CIM
  #def create_cim_profile
  #  return true if customer_cim_id
  #  #Login to the gateway using your credentials in environment.rb
  #  @gateway = GATEWAY
  #
  #  #setup the user object to save
  #  @user = {:profile => user_profile}
  #
  #  #send the create message to the gateway API
  #  response = @gateway.create_customer_profile(@user)
  #
  #  if response.success? and response.authorization
  #    update_attributes({:customer_cim_id => response.authorization})
  #    return true
  #  end
  #  return false
  #end
  #def user_profile
  #  return {:merchant_customer_id => id, :email => email, :description => merchant_description}
  #end
=begin
  #Override ActiveRecord create to add in create_cim_profile
  def create
    if super and create_cim_profile
      #return true if both the user and the CIM profile was created successfully
      return true
    else
      if self.id
        #destroy the instance if it was created
        self.destroy
      end
      return false
    end
  end

  #Override ActiveRecord update to add in update_cim_profile
  def update
    if super < 0 and update_cim_profile
      return true
    end
    return false
  end

  #Override ActiveRecord destroy to add in delete_cim_profile
  def destroy
    if delete_cim_profile and super
      return true
    end
    return false
  end
=end
  private

  def create_cim_profile
    return true if customer_cim_id
    #Login to the gateway using your credentials in environment.rb
    @gateway = CIM_GATEWAY

    #setup the user object to save
    @user = {:profile => user_profile}

    #send the create message to the gateway API
    response = @gateway.create_customer_profile(@user)

    if response.success? and response.authorization
      update_attributes({:customer_cim_id => response.authorization})
      return true
    end
    return false
  end

  def user_profile
    return {:merchant_customer_id => self.id, :email => self.email, :description => self.merchant_description}
  end

  def update_cim_profile
    if not self.customer_cim_id
      return false
    end
    if self.email_changed? || self.first_name_changed? || self.last_name_changed?
      @gateway = CIM_GATEWAY

      response = @gateway.update_customer_profile(:profile => user_profile.merge({
          :customer_profile_id => self.customer_cim_id
        }))

      if response.success?
        return true
      end
      return false
    else
      return true
    end
  end

  def delete_cim_profile
    if not self.customer_cim_id
      return false
    end
    @gateway = CIM_GATEWAY

    response = @gateway.delete_customer_profile(:customer_profile_id => self.customer_cim_id)

    if response.success?
      return true
    end
    return false
  end
end
