Spree::Admin::ProductsController.class_eval do
  respond_to :csv

  def index
    session[:return_to] = request.url
    respond_with(@collection) do |format|
      format.html
      format.csv { send_data Spree::Product.available.to_csv }
    end
  end
end