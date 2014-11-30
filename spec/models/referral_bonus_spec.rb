require 'spec_helper'

describe ReferralBonus do
  context "give_credits(user)" do
    it 'should give store credits to the user' do
      user              = FactoryGirl.create(:user)
      referral_bonus    = FactoryGirl.create(:referral_bonus, :amount => 1000)
      beginning_credits = user.store_credit_amount
      referral_bonus.give_credits(user)
      user.reload
      expect(user.store_credit_amount).to eq beginning_credits + 10.00
    end
  end
end
