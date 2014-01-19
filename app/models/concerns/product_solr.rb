module ProductSolr
  extend ActiveSupport::Concern

  included do
    searchable do
      text    :name, default_boost: 2
      text      :product_keywords#, :multiple => true
      text      :description
      time      :deleted_at
    end
  end

  module ClassMethods
    def standard_search(args, params = {})
      params[:rows] ||= 15
      params[:page] ||= 1
      Product.search(:include => [:properties, :images]) do
        keywords(args)
        any_of do
          with(:deleted_at).greater_than(Time.zone.now)
          with(:deleted_at, nil)
        end
        paginate page: params[:page].to_i, per_page: params[:rows].to_i
      end
    end
  end
end
