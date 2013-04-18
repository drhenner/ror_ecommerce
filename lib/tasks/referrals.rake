namespace :rore do
  namespace :referrals do
    # rake rore:referrals:apply --trace
    task :apply => :environment  do |t,args|
      Referral.unapplied.purchased.find_each do |referral|
        referral.give_credits!
      end
    end
  end
end
