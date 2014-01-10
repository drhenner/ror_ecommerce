module Presentation
  module OrderPresenter
    extend ActiveSupport::Concern

    # user name on the order
    #
    # @param [none]
    # @return [String] user name on the order
    def name
      self.user.name
    end

    # formated date of the complete_at datetime on the order
    #
    # @param [none]
    # @return [String] formated date or 'Not Finished.' if the order is not completed
    def display_completed_at(format = :us_date)
      completed_at ? I18n.localize(completed_at, :format => format) : 'Not Finished.'
    end

    def display_shipping_charges
      items = OrderItem.order_items_in_cart(self.id)
      return 'TBD' if items.any?{|i| i.shipping_rate_id.nil? }
      shipping_charges(items)
    end

  end
end
