module Presentation
  module ProductPresenter
    extend ActiveSupport::Concern

    # range of the product prices in plain english
    #
    # @param [Optional String] separator between the low and high price
    # @return [String] Low price + separator + High price
    def display_price_range(j = ' to ')
      price_range.join(j)
    end

  end
end
