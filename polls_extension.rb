class PollsExtension < Radiant::Extension
  version "0.2"
  description "Allows you to add polls to your radiant site."
  url "http://github.com/nuex/radiant-polls-extension"
  
  define_routes do |map|
    map.connect 'poll/:action', :controller => 'poll'
    map.connect 'admin/polls/:action', :controller => 'admin/polls'
  end
  
  def activate
    admin.tabs.add "Polls", "/admin/polls", :after => "Layouts", :visibility => [:all]
    Page.send :include, PollTags
  end
  
  def deactivate
    admin.tabs.remove "Polls"
  end
  
end
