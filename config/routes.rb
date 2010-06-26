ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :clear_responses => :post } do |admin|
    admin.resources :polls
  end
  map.resources :poll_response, :only => [ :index, :create ], :path_prefix => '/pages/:page_id', :controller => 'poll_response'
end
