class PollsExtension < Radiant::Extension
  version '0.3.1'
  description 'Radiant gets polls.'
  url 'http://github.com/nuex/radiant-polls-extension'

  def activate
    require_dependency 'application_controller'
    tab 'Content' do
      add_item 'Polls', '/admin/polls', :after => 'Pages'
    end
    if Radiant::Config.table_exists?
      Radiant::Config['paginate.url_route'] = '' unless Radiant::Config['paginate.url_route']
      PollsExtension.const_set('UrlCache', Radiant::Config['paginate.url_route'])
    end
    Page.send :include, PollTags
    Page.send :include, PollProcess
    Page.send :include, PollPageExtensions
    Page.send :include, ActionView::Helpers::TagHelper  # Required for pagination
  end

end
