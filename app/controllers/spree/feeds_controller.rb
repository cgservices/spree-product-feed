module Spree
  class FeedsController < Spree::StoreController
    respond_to :xml
    #caches_page :show

    def show
      options = %w(google beslist).include?(params[:id]) ? {file: Rails.root.join(CgConfig::PRODUCT_FEEDS[:asset_path],"#{current_store.code}_#{params[:id]}.xml").to_s, status: 200, layout: false} : {nothing: true, status: 404}
      render options
    end
  end
end