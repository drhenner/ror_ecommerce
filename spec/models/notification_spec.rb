require 'spec_helper'

RSpec.describe InStockNotification, type: :model do

  let(:non_variant)               { FactoryGirl.create(:variant) }
  let(:req_variant)               { FactoryGirl.create(:variant) }
  let(:non_requested_user)        { FactoryGirl.create(:user) }
  let(:requested_user)            { FactoryGirl.create(:user) }
  let(:previously_requested_user) { FactoryGirl.create(:user) }
  let!(:notification1)            { FactoryGirl.create(:in_stock_notification, sent_at: Time.now, user: previously_requested_user, notifiable: req_variant) }
  let!(:notification2)            { FactoryGirl.create(:in_stock_notification, sent_at: nil, user: requested_user, notifiable: req_variant) }
  let!(:notification3)            { FactoryGirl.create(:in_stock_notification, sent_at: nil, user: non_requested_user, notifiable: non_variant) }

  describe '#send!' do
    it 'should send an in stock message to all users that requested' do
       'should not send an in stock message to users that have not requested' # non_requested_user
       'should not send an in stock message to users that have requested and have sent_at set' # previously_requested_user
      in_stock_message = mock()
      in_stock_message.stubs(:deliver_later)
      Notifier.expects(:in_stock_message).with([requested_user.id], [req_variant.id]).once.returns(in_stock_message)
      InStockNotification.send!(req_variant.id)
    end

    it 'should set sent_at for users that have requested' do
      InStockNotification.send!(req_variant.id)
      notification2.reload
      expect(notification2.sent_at).not_to be nil
    end
  end
end

RSpec.describe LowStockNotification, type: :model do
  let(:non_variant)               { FactoryGirl.create(:variant) }
  let(:req_variant)               { FactoryGirl.create(:variant) }
  let(:non_admin_user)            { FactoryGirl.create(:admin_user) }
  let(:inactive_user)             { FactoryGirl.create(:admin_user) }
  let(:admin_user)                { FactoryGirl.create(:admin_user) }
  let!(:notification1)            { FactoryGirl.create(:low_stock_notification, sent_at: nil, user: inactive_user, notifiable: req_variant) }
  let!(:notification2)            { FactoryGirl.create(:low_stock_notification, sent_at: nil, user: admin_user, notifiable: req_variant) }
  let!(:notification3)            { FactoryGirl.create(:low_stock_notification, sent_at: nil, user: non_admin_user, notifiable: non_variant) }

  describe '#send!' do
    it 'should send an in stock message to all users that requested' do
       'should not send an in stock message to users that are no longer an admin' # previously_requested_user
       'should not send an in stock message to users that are no longer active' # previously_requested_user
      non_admin_user.roles.delete_all
      inactive_user.deactivate!
      low_stock_message = mock()
      low_stock_message.stubs(:deliver_later)
      Notifier.expects(:low_stock_message).with([admin_user.id], [req_variant.id]).once.returns(low_stock_message)
      LowStockNotification.send!(req_variant.id)
    end

    it 'should send to admin users if no users are active & specified' do
      non_admin_user.roles.delete_all
      inactive_user.deactivate!
      low_stock_message = mock()
      low_stock_message.stubs(:deliver_later)
      Notifier.expects(:low_stock_message).with([admin_user.id], [non_variant.id]).once.returns(low_stock_message)
      LowStockNotification.send!(non_variant.id)
    end
  end
end

RSpec.describe OutOfStockNotification, type: :model do
  let(:non_variant)               { FactoryGirl.create(:variant) }
  let(:req_variant)               { FactoryGirl.create(:variant) }
  let(:non_admin_user)            { FactoryGirl.create(:admin_user) }
  let(:inactive_user)             { FactoryGirl.create(:admin_user) }
  let(:admin_user)                { FactoryGirl.create(:admin_user) }
  let!(:notification1)            { FactoryGirl.create(:out_of_stock_notification, sent_at: nil, user: inactive_user, notifiable: req_variant) }
  let!(:notification2)            { FactoryGirl.create(:out_of_stock_notification, sent_at: nil, user: admin_user, notifiable: req_variant) }
  let!(:notification3)            { FactoryGirl.create(:out_of_stock_notification, sent_at: nil, user: non_admin_user, notifiable: non_variant) }

  describe '#send!' do
    it 'should send an out of stock message to all users that requested' do
       'should not send an out of stock message to users that are no longer an admin' # previously_requested_user
       'should not send an out of stock message to users that are no longer active' # previously_requested_user
      non_admin_user.roles.delete_all
      inactive_user.deactivate!
      out_of_stock_message = mock()
      out_of_stock_message.stubs(:deliver_later)
      Notifier.expects(:out_of_stock_message).with([admin_user.id], [req_variant.id]).once.returns(out_of_stock_message)
      OutOfStockNotification.send!(req_variant.id)
    end

    it 'should send to admin users if no users are admin & active & specified' do
      non_admin_user.roles.delete_all
      inactive_user.deactivate!
      out_of_stock_message = mock()
      out_of_stock_message.stubs(:deliver_later)
      Notifier.expects(:out_of_stock_message).with([admin_user.id], [non_variant.id]).once.returns(out_of_stock_message)
      OutOfStockNotification.send!(non_variant.id)
    end
  end
end
