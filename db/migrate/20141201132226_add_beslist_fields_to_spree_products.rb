class AddBeslistFieldsToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :beslist_category, :string
  end
end
