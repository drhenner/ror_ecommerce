require 'spec_helper'

describe Payment, " instance methods" do

end

describe Payment, " class methods" do
  before(:each) do
    @amount = 100
  end

  context "#store( credit_card, options = {})" do
    it 'should store the credit card' do
      stor = Payment.store(
                            credit_card(:number => '1')
                          )
      expect(stor.action).to      eq 'store'
      expect(stor.message).to     eq BogusGateway::SUCCESS_MESSAGE
    end
  end

  context "#unstore( profile_key, options = {})" do

    it 'should unstore the payment profile' do
      #GATEWAY.expects(:ssl_post).returns(successful_unstore_response)
      charge = Payment.unstore(  '1')
      expect(charge.success).to     be_truthy
      expect(charge.action).to      eq 'unstore'
      expect(charge.message).to     eq BogusGateway::SUCCESS_MESSAGE
    end

    it 'should not unstore the payment profile' do
      #GATEWAY.expects(:ssl_post).returns(successful_unstore_response)
      charge = Payment.unstore(  '3')
      #  puts charge.inspect
      expect(charge.success).not_to     be_truthy
      expect(charge.action).to      eq 'unstore'
    end
  end

  context "#authorize(amount, credit_card, options = {})" do
    it 'should authorize the payment' do
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '1')
                              )
      expect(auth.success).to be true
      expect(auth.action).to      eq 'authorization'
      expect(auth.message).to     eq BogusGateway::SUCCESS_MESSAGE
      #puts auth.params#[:reference]
      expect(auth[:confirmation_id]).to eq BogusGateway::AUTHORIZATION
    end

    it 'should not authorize the payment with failure' do
      #test failed authorization
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '2')
                              )
      expect(auth.success).not_to     be_truthy
      expect(auth.action).to      eq 'authorization'
      expect(auth.message).to     eq BogusGateway::FAILURE_MESSAGE
    end

    it 'should not authorize the payment with error' do
      #test failed authorization
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '3')
                              )
      expect(auth.success).not_to     be_truthy
      expect(auth.action).to      eq 'authorization'
      expect(auth.message).to     eq BogusGateway::NUMBER_ERROR_MESSAGE
    end
  end

  context "#capture(amount, authorization, options = {})" do
    it 'should capture the payment' do
      capt = Payment.capture( @amount, '123')
      expect(capt.success).to     be true
      expect(capt.action).to      eq 'capture'
      expect(capt.message).to     eq BogusGateway::SUCCESS_MESSAGE
    end
    it 'should not capture the payment for failure' do
      capt = Payment.capture( @amount, '2')
      expect(capt.success).not_to     be_truthy
      expect(capt.action).to      eq 'capture'
      expect(capt.message).to     eq BogusGateway::FAILURE_MESSAGE
    end

    it 'should capture the payment in error state' do
      capt = Payment.capture( @amount, '1')
      expect(capt.success).not_to     be_truthy
      expect(capt.action).to      eq 'capture'
      expect(capt.message).to     eq BogusGateway::CAPTURE_ERROR_MESSAGE
    end

  end

  context "#charge( amount, profile_key, options ={})" do
    it 'should charge the payment' do
      charge = Payment.charge( @amount, credit_card(:number => '1'))
      expect(charge.success).to be true
      expect(charge.action).to      eq 'charge'
      expect(charge.message).to     eq BogusGateway::SUCCESS_MESSAGE
    end
    it 'should charge the payment' do
      charge = Payment.charge( @amount, credit_card(:number => '2'))
      expect(charge.success).not_to     be_truthy
      expect(charge.action).to      eq 'charge'
      expect(charge.message).to     eq BogusGateway::FAILURE_MESSAGE
    end
  end

  context "#validate_card( credit_card, options ={})" do
    skip "test for validate_card( credit_card, options ={})"
  end

  #context "#process(action, amount = nil)" # This method is being exersized by many other methods
end
