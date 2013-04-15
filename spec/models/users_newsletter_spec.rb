require 'spec_helper'

describe UsersNewsletter do
  context 'class methods' do
    before(:each) do
      @newsletter = create(:newsletter, :autosubscribe => true)
      @user = create(:user)
    end

    it 'Users should auto subscribe from all newsletters' do
      expect(@user.newsletter_ids.include?(@newsletter.id)).to be_true
    end
    it 'should unsubscribe from all newsletters' do
      UsersNewsletter.unsubscribe(@user.email, UsersNewsletter.unsubscribe_key(@user.email))
      @user.reload
      expect(@user.newsletter_ids).to eq []
    end
  end
end
