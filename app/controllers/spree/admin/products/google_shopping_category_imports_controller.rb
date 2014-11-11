require 'csv'

module Spree
  module Admin
    module Products
      class GoogleShoppingCategoryImportsController < Spree::Admin::BaseController
        def new
        end

        def create
          csv_file = params[:csv_file]
          CSV.foreach(csv_file.path, headers: true) do |row|
            product_attributes = row.to_hash
            if product = Product.where(id: product_attributes['id'].to_i).first
              product.update_column(:google_shopping_category, product_attributes['category']) unless product_attributes['category'].blank?
              product.update_column(:adult, %w(true).include?(product_attributes['adult']) ? 1 : 0) unless product_attributes['adult'].blank?
            end
          end

          flash[:notice] = Spree.t(:google_shopping_category_imports_success)
          redirect_to admin_products_url
        end
      end
    end
  end
end