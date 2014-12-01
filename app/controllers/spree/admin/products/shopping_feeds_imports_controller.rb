require 'csv'

module Spree
  module Admin
    module Products
      class ShoppingFeedsImportsController < Spree::Admin::BaseController
        def new
        end

        def create
          csv_file = params[:csv_file]
          CSV.foreach(csv_file.path, headers: true) do |row|
            product_attributes = row.to_hash
            if product = Product.where(id: product_attributes['id'].to_i).first
              product.update_attribute(:google_shopping_category, product_attributes['google_category']) unless product_attributes['google_category'].blank?
              product.update_attribute(:beslist_category, product_attributes['beslist_category']) unless product_attributes['beslist_category'].blank?
              product.update_attribute(:adult, %w(true).include?(product_attributes['adult']) ? 1 : 0) unless product_attributes['adult'].blank?
              product.update_attribute(:ean_code, product_attributes['ean_code']) unless product_attributes['ean_code'].blank?
            end
          end

          flash[:notice] = Spree.t(:shopping_category_imports_success)
          redirect_to admin_products_url
        end
      end
    end
  end
end