class PollsExtension < Radiant::Extension
  version '0.3.0'
  description 'Radiant gets polls.'
  url 'http://github.com/nuex/radiant-polls-extension'
  
  define_routes do |map|
    map.namespace :admin, :member => { :clear_responses => :post } do |admin|
      admin.resources :polls
    end
    map.resources :poll_response, :only => [ :index, :create ], :path_prefix => '/pages/:page_id', :controller => 'poll_response'
  end
  
  def activate
    require_dependency 'application_controller'
    admin.tabs.add 'Polls', '/admin/polls', :after => 'Layouts', :visibility => [:all]
    Page.send :include, PollTags
    Page.send :include, PollProcess
    Page.send :include, PollPageExtensions
  end
  
  def deactivate
    # Not used
  end
  
end
