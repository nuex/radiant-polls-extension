class PollsExtension < Radiant::Extension
  version '0.2'
  description 'Radiant gets polls.'
  url 'http://github.com/nuex/radiant-polls-extension'
  
  define_routes do |map|
    map.resources :poll_response, :path_prefix => '/pages/:page_id', :controller => 'poll_response'
    map.connect '/admin/polls/:action', :controller => 'admin/polls'
  end
  
  def activate
    admin.tabs.add 'Polls', '/admin/polls', :after => 'Layouts', :visibility => [:all]
    SiteController.class_eval{
      session :disabled => false
    }
    Page.send :include, PollTags
    Page.send :include, PollProcess
    ResponseCache.defaults[:perform_caching] = false
  end
  
  def deactivate
    admin.tabs.remove 'Polls'
  end
  
end
