

describe Notifier, "Signup Email" do
    #include EmailSpec::Helpers
    #include EmailSpec::Matchers
    #include ActionController::UrlWriter
    include Rails.application.routes.url_helpers

    before(:each) do
      #"jojo@yahoo.com", "Jojo Binks"
      #[first_name.capitalize, last_name.capitalize ]
      @user  = create(:user, :email => 'myfake@email.com', :first_name => 'Dave', :last_name => 'Commerce')
      @email = Notifier.signup_notification(@user)
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("Dave Commerce <myfake@email.com>")
    end

    it "should contain the user's message in the mail body" do
      @email.should have_body_text(/Dave Commerce/)
    end

    #it "should contain a link to the confirmation link" do
    #  @email.should have_body_text(/#{confirm_account_url}/)
    #end

    it "should have the correct subject" do
      @email.should have_subject(/New account information/)
    end

end

describe Notifier, "#order_confirmation" do
    #include EmailSpec::Helpers
    #include EmailSpec::Matchers
    #include ActionController::UrlWriter
    include Rails.application.routes.url_helpers

    before(:each) do
      #"jojo@yahoo.com", "Jojo Binks"
      #[first_name.capitalize, last_name.capitalize ]
      @user         = create(:user, :email => 'myfake@email.com', :first_name => 'Dave', :last_name => 'Commerce')
      @order_item   = create(:order_item)
      @order        = create(:order, :email => 'myfake@email.com', :user => @user)
      @invoice        = create(:invoice, :order => @order)
      @order.stubs(:order_items).returns([@order_item])
      @email = Notifier.order_confirmation(@order, @invoice)
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("myfake@email.com")
    end

    it "should contain the user's message in the mail body" do
      @email.should have_body_text(/Dave Commerce/)
    end

    #it "should contain a link to the confirmation link" do
    #  @email.should have_body_text(/#{confirm_account_url}/)
    #end

    it "should have the correct subject" do
      @email.should have_subject(/Order Confirmation/)
    end

end