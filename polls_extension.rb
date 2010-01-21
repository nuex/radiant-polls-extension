class PollsExtension < Radiant::Extension
  version '0.3.1'
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
    if Radiant::Config.table_exists?
      Radiant::Config['paginate.url_route'] = '' unless Radiant::Config['paginate.url_route']
      PollsExtension.const_set('UrlCache', Radiant::Config['paginate.url_route'])
    end
    Page.send :include, PollTags
    Page.send :include, PollProcess
    Page.send :include, PollPageExtensions
    Page.send :include, ActionView::Helpers::TagHelper  # Required for pagination
  end

  def deactivate
    # Not used
  end

end
