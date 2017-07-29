

describe Notifier, "Signup Email" do
    #include EmailSpec::Helpers
    #include EmailSpec::Matchers
    #include ActionController::UrlWriter
    include Rails.application.routes.url_helpers

    before(:each) do
      #"jojo@yahoo.com", "Jojo Binks"
      #[first_name.capitalize, last_name.capitalize ]
      @user  = FactoryGirl.create(:user, :email => 'myfake@email.com', :first_name => 'Dave', :last_name => 'Commerce')
      @email = Notifier.signup_notification(@user.id)
    end

    it "should be set to be delivered to the email passed in" do
      expect(@email).to deliver_to("Dave Commerce <myfake@email.com>")
    end

    it "should contain the user's message in the mail body" do
      expect(@email).to have_body_text(/RoR Ecommerce newsletter/)
    end

    #it "should contain a link to the confirmation link" do
    #  expect(@email).to have_body_text(/#{confirm_account_url}/)
    #end

    it "should have the correct subject" do
      expect(@email).to have_subject(/New account information/)
    end

end

describe Notifier, "#new_referral_credits" do
  include Rails.application.routes.url_helpers

  before(:each) do
    @referring_user = FactoryGirl.create(:user,     :email => 'referring_user@email.com', :first_name => 'Dave', :last_name => 'Commerce')
    @referral       = FactoryGirl.create(:referral, :email => 'referral_user@email.com', :referring_user => @referring_user )
    @referral_user  = FactoryGirl.create(:user,     :email => 'referral_user@email.com', :first_name => 'Dave', :last_name => 'referral')

    #@referral_user.stubs(:referree).returns(@referral)
    @email = Notifier.new_referral_credits(@referring_user.id, @referral_user.id)
  end
  it "should be set to be delivered to the email passed in" do
    expect(@email).to deliver_to("referring_user@email.com")
  end

  it "should have the correct subject" do
    expect(@email).to have_subject(/Referral Credits have been Applied/)
  end
end


describe Notifier, "#referral_invite(referral_id, inviter_id)" do
  include Rails.application.routes.url_helpers

  before(:each) do
    @referring_user = FactoryGirl.create(:user,     :email => 'referring_user@email.com', :first_name => 'Dave', :last_name => 'Commerce')
    @referral       = FactoryGirl.create(:referral, :email => 'referral_user@email.com', :referring_user => @referring_user )

    #@referral_user.stubs(:referree).returns(@referral)
    @email = Notifier.referral_invite(@referral.id, @referring_user.id)
  end
  it "should be set to be delivered to the email passed in" do
    expect(@email).to deliver_to("referral_user@email.com")
  end

  it "should have the correct subject" do
    expect(@email).to have_subject(/Referral from Dave/)
  end
end

describe Notifier, "#order_confirmation" do
    include Rails.application.routes.url_helpers

    before(:each) do
      @user         = FactoryGirl.create(:user, :email => 'myfake@email.com', :first_name => 'Dave', :last_name => 'Commerce')
      @order_item   = FactoryGirl.create(:order_item)
      @order        = FactoryGirl.create(:order, :email => 'myfake@email.com', :user => @user)
      @invoice        = FactoryGirl.create(:invoice, :order => @order)
      @order.stubs(:order_items).returns([@order_item])
      @email = Notifier.order_confirmation(@order.id, @invoice.id)
    end

    it "should be set to be delivered to the email passed in" do
      expect(@email).to deliver_to("myfake@email.com")
    end

    it "should contain the user's message in the mail body" do
      expect(@email).to have_body_text(/Dave Commerce/)
    end

    #it "should contain a link to the confirmation link" do
    #  expect(@email).to have_body_text(/#{confirm_account_url}/)
    #end

    it "should have the correct subject" do
      expect(@email).to have_subject(/Order Confirmation/)
    end

end
