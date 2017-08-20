class Role < ApplicationRecord

  has_many    :user_roles,                      :dependent => :destroy
  has_many    :users,         :through => :user_roles

  validates :name, presence: true, :length => { :maximum => 55 }

  SUPER_ADMIN       = 'super_administrator'
  ADMIN             = 'administrator'
  WAREHOUSE         = 'warehouse'
  REPORT            = 'report'
  CUSTOMER_SERVICE  = 'customer_service'

  ROLES = [ SUPER_ADMIN,
            ADMIN,
            WAREHOUSE,
            REPORT,
            CUSTOMER_SERVICE]

  NON_ADMIN_ROLES = [ WAREHOUSE,
                      REPORT,
                      CUSTOMER_SERVICE]

  SUPER_ADMIN_ID      = 1
  ADMIN_ID            = 2
  WAREHOUSE_ID        = 3
  REPORT_ID           = 4
  CUSTOMER_SERVICE_ID = 5

end
