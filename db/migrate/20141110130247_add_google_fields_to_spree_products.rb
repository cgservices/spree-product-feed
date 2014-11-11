class AddGoogleFieldsToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :google_shopping_category, :string
    add_column :spree_products, :adult, :boolean
  end
end
