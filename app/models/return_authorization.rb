class ReturnAuthorization < ActiveRecord::Base
  has_many   :return_items
  has_many   :comments, :as => :commentable

  belongs_to :user
  belongs_to :order
  belongs_to :author, :class_name => 'User', :foreign_key => :created_by
  # has_many :transactions
  has_many    :transaction_ledgers, :as => :accountable

  accepts_nested_attributes_for :return_items,  :reject_if => proc { |attributes| attributes['return_reason_id'].blank? ||
                                                                                  attributes['return_condition_id'].blank? }
  accepts_nested_attributes_for :comments,      :reject_if => proc { |attributes| attributes['note'].blank? }

  #validates :number,      :presence => true
  validates :amount,      :presence     => true,
                          :numericality => true

  validates :restocking_fee, :numericality => true, :allow_nil => true

  validates :user_id,     :presence => true
  validates :order_id,    :presence => true
  validates :created_by,  :presence => true
  validate :ensure_refund_is_larger_than_restocking

  after_create      :save_order_number

  NUMBER_SEED     = 1002003004005
  CHARACTERS_SEED = 21

  ## after you process an RMA you must manually add the variant back into the system!!!
  state_machine :initial => 'authorized' do
    #after_transition :to => 'received', :do => :process_receive
    #after_transition :to => 'cancelled', :do => :process_canceled
    before_transition :to => 'complete', :do => :process_ledger_transactions

    event :receive do
      transition :to => 'received', :from => 'authorized'
    end
    event :cancel do
      transition :to => 'cancelled', :from => 'authorized'
    end
    event :complete do # do this after a payment was returned to the customer
      transition :to => 'complete', :from => 'authorized'
    end
  end

  def ensure_refund_is_larger_than_restocking
    if restocking_fee && restocking_fee >= amount
      self.errors.add(:amount, "The amount must be larger than the restocking fee.")
    end
  end

  def process_ledger_transactions
    ##  credit => cash
    ##  debit  => revenue
    Invoice.process_rma(amount - restocking_fee, order )
  end

  def order_number
    order.number
  end

  def user_name
    user.name
  end

  def set_number
    return set_order_number if self.id
    self.number = (Time.now.to_i).to_s(CHARACTERS_SEED)## fake number for friendly_id validator
  end

  def set_order_number
    self.number = (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end

  def save_order_number
    set_order_number
    save
  end

  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end

  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end

  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = ReturnAuthorization.includes([:return_items, :order, :user])#paginate({:page => params[:page]})

    grid = grid.where("return_authorizations.number LIKE ?",  "#{params[:number]}%")        if params[:number].present?
    grid = grid.where("orders.order_number LIKE ?",           "#{params[:order_number]}%")  if params[:order_number].present?
    grid = grid.where("return_authorizations.state = ?",      params[:state])               if params[:state].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page], :per_page => params[:rows])
  end
end
