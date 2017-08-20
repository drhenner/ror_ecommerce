# == Schema Information
#
# Table name: return_items
#
#  id                      :integer(4)      not null, primary key
#  return_authorization_id :integer(4)      not null
#  order_item_id           :integer(4)      not null
#  return_condition_id     :integer(4)
#  return_reason_id        :integer(4)
#  returned                :boolean(1)      default(FALSE)
#  updated_by              :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#

class ReturnItem < ApplicationRecord
  belongs_to :return_reason
  belongs_to :return_condition

  belongs_to :return_authorization
  belongs_to :order_item
  belongs_to :last_author, :class_name => 'User', :foreign_key => :updated_by
  belongs_to :author, :class_name => 'User', :foreign_key => "created_by"


  validates :order_item_id,           presence: true
  validates :return_condition_id,     presence: true
  validates :return_reason_id,        presence: true
  #validates :return_authorization_id, presence: true

  def mark_returned!
    self.returned = true
    self.order_item.return!
    save
  end
end
