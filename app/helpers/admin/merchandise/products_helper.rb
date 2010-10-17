module Admin::Merchandise::ProductsHelper

   # example usage
   # def add_new_info_link('add XYZ', 'admin/merchandise/add_product', Product.new, :products, 'admin-merchandise-products', form)
   def add_new_info_link(name, partial, object, symbol, add_to_this_id, form)
     link_to_function name do |page|
       form.fields_for symbol, object, :child_index => 'NEW_RECORD' do |f|
         html = render(:partial => partial, :locals => { :form => f })
         page << "$('#{add_to_this_id}').insert({ bottom: '#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
       end
     end
   end
end
