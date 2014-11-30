require 'spec_helper'

describe Referral do
  context ".give_credits!" do
    it 'should apply credit to referral' do
      referring_user = FactoryGirl.create(:user)
      referral_bonus    = FactoryGirl.create(:referral_bonus, :amount => 1000)
      referral_program  = FactoryGirl.create(:referral_program, :referral_bonus => referral_bonus)# refer 2 get $10
      referral          = FactoryGirl.create(:referral,
                          :referring_user   => referring_user,
                          :referral_user    => nil,
                          :referral_program => referral_program,
                          :registered_at    => nil)
      referral_user = FactoryGirl.create(:user, :email => referral.email)
      referral.purchased_at = Time.zone.now
      referral.save
      email_mock = mock()
      email_mock.stubs(:deliver)
      Notifier.stubs(:new_referral_credits).returns(email_mock)
      referral.referral_program.expects(:give_credits).once
      referral.give_credits!
      referral.reload
      expect(referral.applied).to be true
    end
  end

  it 'should set_referral_registered_at' do
    referring_user = FactoryGirl.create(:user)
    referral_bonus    = FactoryGirl.create(:referral_bonus, :amount => 1000)
    referral_program  = FactoryGirl.create(:referral_program, :referral_bonus => referral_bonus)# refer 2 get $10
    referral          = FactoryGirl.create(:referral,
                        :email            => 'john@doe.com',
                        :referring_user   => referring_user,
                        :referral_user    => nil,
                        :referral_program => referral_program,
                        :registered_at    => nil)
    referral_user = FactoryGirl.create(:user, :email => 'john@doe.com')
    referral.reload
    expect(referral.referral_user_id).to eq referral_user.id
    expect(referral.registered_at).not_to be_nil
  end
end
