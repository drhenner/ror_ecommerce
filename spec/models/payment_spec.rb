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
      stor.action.should      == 'store'
      stor.message.should     == BogusGateway::SUCCESS_MESSAGE
    end
  end

  context "#unstore( profile_key, options = {})" do

    it 'should unstore the payment profile' do
      #GATEWAY.expects(:ssl_post).returns(successful_unstore_response)
      charge = Payment.unstore(  '1')
      charge.success.should     be_true
      charge.action.should      == 'unstore'
      charge.message.should     == BogusGateway::SUCCESS_MESSAGE
    end

    it 'should not unstore the payment profile' do
      #GATEWAY.expects(:ssl_post).returns(successful_unstore_response)
      charge = Payment.unstore(  '3')
      #  puts charge.inspect
      charge.success.should_not     be_true
      charge.action.should      == 'unstore'
    end
  end

  context "#authorize(amount, credit_card, options = {})" do
    it 'should authorize the payment' do
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '1')
                              )
      auth.success.should     be_true
      auth.action.should      == 'authorization'
      auth.message.should     == BogusGateway::SUCCESS_MESSAGE
      #puts auth.params#[:reference]
      auth[:confirmation_id].should == BogusGateway::AUTHORIZATION
    end

    it 'should not authorize the payment with failure' do
      #test failed authorization
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '2')
                              )
      auth.success.should_not     be_true
      auth.action.should      == 'authorization'
      auth.message.should     == BogusGateway::FAILURE_MESSAGE
    end

    it 'should not authorize the payment with error' do
      #test failed authorization
      auth = Payment.authorize(
                                @amount,
                                credit_card(:number => '3')
                              )
      auth.success.should_not     be_true
      auth.action.should      == 'authorization'
      auth.message.should     == BogusGateway::ERROR_MESSAGE
    end
  end

  context "#capture(amount, authorization, options = {})" do
    it 'should capture the payment' do
      capt = Payment.capture( @amount, '123')
      capt.success.should     be_true
      capt.action.should      == 'capture'
      capt.message.should     == BogusGateway::SUCCESS_MESSAGE
    end
    it 'should not capture the payment for failure' do
      capt = Payment.capture( @amount, '2')
      capt.success.should_not     be_true
      capt.action.should      == 'capture'
      capt.message.should     == BogusGateway::FAILURE_MESSAGE
    end

    it 'should capture the payment in error state' do
      capt = Payment.capture( @amount, '1')
      capt.success.should_not     be_true
      capt.action.should      == 'capture'
      capt.message.should     == BogusGateway::CAPTURE_ERROR_MESSAGE
    end

  end

  context "#charge( amount, profile_key, options ={})" do
    it 'should charge the payment' do
      charge = Payment.charge( @amount, credit_card(:number => '1'))
      charge.success.should     be_true
      charge.action.should      == 'charge'
      charge.message.should     == BogusGateway::SUCCESS_MESSAGE
    end
    it 'should charge the payment' do
      charge = Payment.charge( @amount, credit_card(:number => '2'))
      charge.success.should_not     be_true
      charge.action.should      == 'charge'
      charge.message.should     == BogusGateway::FAILURE_MESSAGE
    end
  end

  context "#validate_card( credit_card, options ={})" do
    pending "test for validate_card( credit_card, options ={})"
  end

  #context "#process(action, amount = nil)" # This method is being exersized by many other methods
end