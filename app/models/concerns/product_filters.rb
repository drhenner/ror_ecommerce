module ProductFilters
  extend ActiveSupport::Concern
  module ClassMethods

    # paginated results from the admin products grid
    #
    # @param [Optional params]
    # @param [Optional Boolean] the state of the product you are searching (active == true)
    # @return [ Array[Product] ]
    def admin_grid(params = {}, active_state = nil)
      grid = includes(:variants).
                  deleted_at_filter(active_state).
                  name_filter(params[:name]).
                  product_type_filter( params[:product_type_id] ).
                  shipping_category_filter(params[:shipping_category_id]).
                  available_at_gt_filter(params[:available_at_gt]).
                  available_at_lt_filter(params[:available_at_lt])
    end

    # These methods are only called via the admin_grid method
    # private

      def available_at_lt_filter(available_at_lt)
        if available_at_lt.present?
          where("products.available_at <= ?", available_at_lt)
        else
          all
        end
      end

      def available_at_gt_filter(available_at_gt)
        if available_at_gt.present?
          where("products.available_at >= ?", available_at_gt)
        else
          all
        end
      end
      def shipping_category_filter(shipping_category_id)
        if shipping_category_id.present?
          where("products.shipping_category_id = ?", shipping_category_id)
        else
          all
        end
      end

      def product_type_filter(product_type_id)
        if product_type_id.present?
          if product_type_id.present? && product_type = ProductType.find_by_id(product_type_id)
            product_types = product_type.self_and_descendants.map(&:id)
          end
          where(products: { product_type_id: product_types })
        else
          all
        end
      end

      def name_filter(name)
        if name.present?
          where("products.name LIKE ?", "#{name}%")
        else
          all
        end
      end

      def deleted_at_filter(active_state)
        if active_state
          active
        elsif active_state == false##  note nil != false
          where(['products.deleted_at IS NOT NULL AND products.deleted_at <= ?', Time.zone.now.to_s(:db)])
        else
          all
        end
      end
  end
end
