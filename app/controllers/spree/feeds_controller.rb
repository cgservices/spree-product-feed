module Spree
  class FeedsController < Spree::StoreController
    respond_to :xml

    def show
      # p = Spree::Product.arel_table
      # v = Spree::Variant.arel_table
      # s = Spree::Store.arel_table
      # ps = Arel::Table.new(:spree_products_stores)
      # query = p.join(ps).on(ps[:product_id].eq(p[:id])).join(s).on(ps[:product_id].eq(p[:id])).where(ps[:store_id].eq(params[:current_store_id])).join(v).on(v[:product_id].eq(p[:id])).project(Arel.sql('*'))
      # @products = Spree::Product.find_by_sql(query.to_sql)
      params.merge!(per_page: 10000)
      searcher = build_searcher(params)

      @products = Rails.cache.fetch("product_feed_#{params[:id]}", expires_in: 1.hour, race_condition_ttl: 2.minutes) do
        searcher.retrieve_products.includes(:variants).includes(product_properties: :property).includes(:prices).all
      end

      options = %w(google beslist).include?(params[:id]) ? {template: "spree/feeds/#{params[:id]}", status: 200, layout: false} : {nothing: true, status: 404}

      respond_to do |format|
        format.xml { render(options)}
      end
    end
  end
end