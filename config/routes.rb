Spree::Core::Engine.routes.draw do
  get 'feeds/:id', to: "feeds#show", :defaults => { :format => 'xml' }
end
