class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role, required: true

 # validates :user_id,  presence: true
 # validates :role_id,  presence: true

end
