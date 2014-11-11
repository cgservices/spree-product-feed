Spree::Core::Engine.routes.draw do
  get 'feeds/:id', to: "feeds#show", :defaults => { :format => 'xml' }

  namespace :admin do
    namespace :products do
      resources :google_shopping_category_imports, only: [:new, :create]
    end
  end
end
