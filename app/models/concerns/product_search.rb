module ProductSearch
  extend ActiveSupport::Concern

  included do
    # Searchkick 6.x stores :class_name in model_options internally, which
    # leaks across Zeitwerk class reloads in development and fails the
    # keyword allowlist check on the next load.  Scrub it pre-emptively.
    Searchkick.model_options.delete(:class_name) if Searchkick.model_options.key?(:class_name)
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
      page = params[:page].to_i
      per_page = params[:per_page].to_i
      Product.includes(:properties, :images, :active_variants).active
             .where("products.name LIKE :q OR products.meta_keywords LIKE :q", q: "%#{args}%")
             .limit(per_page).offset((page - 1) * per_page)
    end
  end
end
