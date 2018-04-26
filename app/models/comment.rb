# == Schema Information
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  note             :text
#  commentable_type :string(255)
#  commentable_id   :integer(4)
#  created_by       :integer(4)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :author, class_name: 'User', foreign_key: "created_by"
  belongs_to :user, counter_cache: true

  validates :note,              presence: true,       length: { maximum: 1255 }
  validates :commentable_type,  presence: true
  # validates :commentable_id,    presence: true
end
