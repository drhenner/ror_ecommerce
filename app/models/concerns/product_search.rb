module ProductSearch
  extend ActiveSupport::Concern

  included do
    searchkick word_start: [:name]
  end

  def search_data
    {
      name: name,
      product_keywords: product_keywords,
      description: description_markup,
      deleted_at: deleted_at
    }
  end

  module ClassMethods
    def standard_search(args, params = {})
      params[:page] ||= 1
      params[:per_page] ||= 15
      relation = Product.search(args,
        fields: ["name^2", "product_keywords", "description"],
        where: { _or: [{ deleted_at: nil }, { deleted_at: { gt: Time.zone.now } }] },
        includes: [:properties, :images, :active_variants],
        page: params[:page].to_i,
        per_page: params[:per_page].to_i
      )
      relation.results
      relation
    rescue Elastic::Transport::Transport::Error
      Product.includes(:properties, :images, :active_variants).active
             .where("products.name LIKE :q OR products.meta_keywords LIKE :q", q: "%#{args}%")
             .paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
    end
  end
end
