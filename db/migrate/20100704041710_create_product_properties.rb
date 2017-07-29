class CreateProductProperties < ActiveRecord::Migration[4.2]
  def self.up
    create_table :product_properties do |t|
      t.integer     :product_id, :null => false
      t.integer     :property_id, :null => false
      t.integer     :position
      t.string      :description, :null => false
    end

    add_index :product_properties, :product_id
    add_index :product_properties, :property_id

    if SETTINGS[:use_foreign_keys]
      execute "alter table product_properties add constraint fk_product_properties_prototypes foreign key (product_id) references products(id)"
      execute "alter table product_properties add constraint fk_product_properties_properties foreign key (property_id) references properties(id)"
    end
  end

  def self.down
    if SETTINGS[:use_foreign_keys]
      execute "alter table product_properties drop foreign key fk_product_properties_prototypes"
      execute "alter table product_properties drop foreign key fk_product_properties_properties"
    end
    drop_table :product_properties
  end
end
