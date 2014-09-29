module Spree
  class FeedsController < Spree::StoreController
    respond_to :xml

    def show
      params.merge!(per_page: 10000)
      @searcher = build_searcher(params)
      @products = @searcher.retrieve_products.includes(:variants).includes(product_properties: :property).where('spree_properties.name' => ['brand', 'color']).includes(:prices).where('spree_prices.currency' => 'EUR')
      options = %w(google beslist).include?(params[:id]) ? {template: "spree/feeds/#{params[:id]}", status: 200, layout: false} : {nothing: true, status: 404}

      respond_to do |format|
        format.xml { render(options)}
      end
    end
  end
end