# -*- coding: utf-8 -*-
module PollTags
  include Radiant::Taggable
  include WillPaginate::ViewHelpers

  class RadiantLinkRenderer < WillPaginate::LinkRenderer
    include ActionView::Helpers::TagHelper

    def initialize(tag)
      @tag = tag
    end

    def page_link(page, text, attributes = {})
      attributes = tag_options(attributes)
      @paginate_url_route = @paginate_url_route.blank? ? PollsExtension::UrlCache : @paginate_url_route
      %Q{<a href="#{@tag.locals.page.url}#{@paginate_url_route}#{page}"#{attributes}>#{text}</a>}
    end

    def gap_marker
      '<span class="gap">&#8230;</span>'
    end

    def page_span(page, text, attributes = {})
      attributes = tag_options(attributes)
      "<span#{attributes}>#{text}</span>"
    end
  end

  class TagError < StandardError; end

  ##
  ## Individual polls
  ##

  desc %{
    Selects the active poll.

    *Usage:*
    <pre><code><r:poll [title="poll_title"]>...</r:poll></code></pre>
  }
  tag 'poll' do |tag|
    options = tag.attr.dup
    tag.locals.page.cache = false
    if Poll.count > 0
      tag.locals.poll = find_poll(tag, options)
      tag.expand
    else
      'No polls found'
    end
  end

  desc %{
    Expands inner tags if the poll has not been submitted yet.

    *Usage:*
    <pre><code><r:poll:unless_submitted>...</r:poll:unless_submitted></code></pre>

  }
  tag 'poll:unless_submitted' do |tag|
    options = tag.attr.dup
    poll = tag.locals.poll = find_poll(tag, options)
    tag.expand unless tag.locals.page.submitted_polls && tag.locals.page.submitted_polls.include?(poll.id)
  end

  desc %{
    Expands inner tags if the poll has been submitted.

    *Usage:*
    <pre><code><r:poll:if_submitted>...</r:poll:if_submitted></code></pre>

  }
  tag 'poll:if_submitted' do |tag|
    options = tag.attr.dup
    poll = tag.locals.poll = find_poll(tag, options)
    tag.expand if tag.locals.page.submitted_polls && tag.locals.page.submitted_polls.include?(poll.id)
  end

  desc %{
    Shows the poll title.

    *Usage:*
    <pre><code><r:poll [title="My Poll"]><r:title /></r:poll></code></pre>
  }
  tag 'poll:title' do |tag|
    tag.locals.poll.title
  end

  desc %{
    Renders a poll survey form.

    *Usage:*
    <pre><code><r:poll [title="My Poll"]><r:form>...</r:form></r:poll></code></pre>
  }
  tag 'poll:form' do |tag|
    options = tag.attr.dup
    tag.locals.poll = find_poll(tag, options)
    poll = tag.locals.poll
    result = %Q{
      <form action="/pages/#{tag.locals.page.id}/poll_response" method="post" id="poll_form">
        <div>
          #{tag.expand}
          <input type="hidden" name="poll_id" value="#{tag.locals.poll.id}" />
        </div>
      </form>
    }
  end

  desc %{
    A collection of options, optionally sorted by response_count in
    ASCending, DESCending, or RANDom order. If no order is specified
    the result will be in whatever order is returned by the SQL query.

    *Usage:*
    <pre><code><r:poll:options [order="asc|desc|rand"]>...</r:poll:options></code></pre>
  }
  tag 'poll:options' do |tag|
    tag.locals.sort_order = case tag.attr['order']
                            when /^asc/i
                              lambda { |a,b| a.response_count <=> b.response_count }
                            when /^desc/i
                              lambda { |a,b| b.response_count <=> a.response_count }
                            when /^rand/i
                              lambda { rand(3) - 1 }
                            else
                              nil
                            end
    tag.expand
  end

  desc %{
    Iterate through each poll option.

    *Usage:*
    <pre><code><r:poll:options:each>...</r:poll:options:each></code></pre>
  }
  tag 'poll:options:each' do |tag|
    result = []
    options = tag.locals.sort_order.nil? ? tag.locals.poll.options : tag.locals.poll.options.sort(&tag.locals.sort_order)
    options.each do |option|
      tag.locals.option = option
      result << tag.expand
    end
    result
  end

  desc %{
    Render inner content if the current contextual option is the first option.

    *Usage:*
    <pre><code><r:poll:options:each:if_first>...</r:poll:options:each:if_first></code></pre>
  }
  tag 'poll:options:each:if_first' do |tag|
    options = tag.locals.sort_order.nil? ? tag.locals.poll.options : tag.locals.poll.options.sort(&tag.locals.sort_order)
    if options.first == tag.locals.option
      tag.expand
    end
  end

  desc %{
    Render inner content if the current contextual option is the last option.

    *Usage:*
    <pre><code><r:poll:options:each:if_last>...</r:poll:options:each:if_last></code></pre>
  }
  tag 'poll:options:each:if_last' do |tag|
    options = tag.locals.sort_order.nil? ? tag.locals.poll.options : tag.locals.poll.options.sort(&tag.locals.sort_order)
    if options.last == tag.locals.option
      tag.expand
    end
  end

  desc %{
    Render inner content unless the current contextual option is the first option.

    *Usage:*
    <pre><code><r:poll:options:each:unless_first>...</r:poll:options:each:unless_first></code></pre>
  }
  tag 'poll:options:each:unless_first' do |tag|
    options = tag.locals.sort_order.nil? ? tag.locals.poll.options : tag.locals.poll.options.sort(&tag.locals.sort_order)
    unless options.first == tag.locals.option
      tag.expand
    end
  end

  desc %{
    Render inner content unless the current contextual option is the last option.

    *Usage:*
    <pre><code><r:poll:options:each:unless_last>...</r:poll:options:each:unless_last></code></pre>
  }
  tag 'poll:options:each:unless_last' do |tag|
    options = tag.locals.sort_order.nil? ? tag.locals.poll.options : tag.locals.poll.options.sort(&tag.locals.sort_order)
    unless options.last == tag.locals.option
      tag.expand
    end
  end

  desc %{
    Show the poll option radio button input type.

    *Usage:*
    <pre><code><r:poll:form><r:options:each><r:input /><r:title /></r:options:each></r:poll:form></code></pre>
  }
  tag 'poll:options:input' do |tag|
    option = tag.locals.option
    %{<input type="radio" name="response_id" value="#{option.id}" />}
  end

  desc %{
    Show the poll option title.

    *Usage:*
    <pre><code><r:poll:options:each><r:title /></r:poll:options:each></code></pre>
  }
  tag 'poll:options:title' do |tag|
    tag.locals.option.title
  end

  desc %{
    Show a poll form submit button.

    *Usage:*
    <pre><code><r:poll:form><r:options:each><r:input /><r:title /></r:options:each><r:submit [value="Go!"] /></r:poll:form></code></pre>
  }
  tag 'poll:submit' do |tag|
    value = tag.attr['value'] || 'Submit'
    %{<input type="submit" name="poll[submit]" value="#{value}" />}
  end

  desc %{
    Show percentage of responses for a particular option.

    *Usage:*
    <pre><code><r:poll:options:each><r:title /> <r:percent_responses /></r:poll:options:each></code></pre>
  }
  tag 'options:percent_responses' do |tag|
    tag.locals.option.response_percentage
  end

  desc %{
    Show count of responses for a particular option.

    *Usage:*
    <pre><code><r:poll:options:each><r:title /> <r:number_responded /></r:poll:options:each></code></pre>
  }
  tag 'options:number_responses' do |tag|
    tag.locals.option.response_count
  end

  desc %{
    Show total number of visitors that responded.

    *Usage:*
    <pre><code><r:poll:total_responses /></code></pre>
  }
  tag 'poll:total_responses' do |tag|
    tag.locals.poll.response_count
  end

  tag 'poll_test' do |tag|
    "#{tag.locals.page.request.cookies.inspect}"
  end

  ##
  ## Collections of polls
  ##

  desc %{
    Selects all polls.

    By default, polls are sorted in ascending order by title and limited to 10 per page;
    the current poll and any future polls are excluded. To include the current poll, set
    show_current = "true". Any polls where @attribute@ is null are also excluded, so if
    you have a set of polls that include polls that do not have a defined start date, then
    when specifying @by="start_date"@ only those polls with start dates will be shown.

    *Usage:*
    <pre><code><r:polls [per_page="10"] [by="attribute"] [order="asc|desc"] [show_current="true|false"] /></code></pre>
  }
  tag 'polls' do |tag|
    if Poll.count > 0
      options = find_options(tag)

      tag.locals.paginated_polls = Poll.paginate(options)
      tag.expand
    else
      'No polls found'
    end
  end

  desc %{
    Loops through each poll and renders the contents.

    *Usage:*
    <pre><code><r:polls:each>...</r:polls:each></code></pre>
  }
  tag 'polls:each' do |tag|
    result = []

    tag.locals.paginated_polls.each do |poll|
      tag.locals.poll = poll
      result << tag.expand
    end

    result
  end

  desc %{
    Creates the context for a single poll.

    *Usage:*
    <pre><code><r:polls:each:poll>...</r:polls:each:poll></code></pre>
  }
  tag 'polls:each:poll' do |tag|
    tag.expand
  end

  desc %{
    Renders pagination links with will_paginate
    The following optional attributes may be controlled:

    * id - the id to apply to the containing @<div>@
    * class - the class to apply to the containing @<div>@
    * previous_label - default: "« Previous"
    * prev_label - deprecated variant of previous_label
    * next_label - default: "Next »"
    * inner_window - how many links are shown around the current page (default: 4)
    * outer_window - how many links are around the first and the last page (default: 1)
    * separator - string separator for page HTML elements (default: single space)
    * page_links - when false, only previous/next links are rendered (default: true)
    * container - when false, pagination links are not wrapped in a containing @<div>@ (default: true)

    *Usage:*

    <pre><code><r:polls>
      <r:pages [id=""] [class="pagination"] [previous_label="&laquo; Previous"]
      [next_label="Next &raquo;"] [inner_window="4"] [outer_window="1"]
      [separator=" "] [page_links="true"] [container="true"]/>
    </r:polls></code></pre>
  }
  tag 'polls:pages' do |tag|
    renderer = RadiantLinkRenderer.new(tag)

    options = {}

    [:id, :class, :previous_label, :prev_label, :next_label, :inner_window, :outer_window, :separator].each do |a|
      options[a] = tag.attr[a.to_s] unless tag.attr[a.to_s].blank?
    end
    options[:page_links] = false if 'false' == tag.attr['page_links']
    options[:container]  = false if 'false' == tag.attr['container']

    will_paginate tag.locals.paginated_polls, options.merge(:renderer => renderer)
  end

  private

  def find_poll(tag, options)
    unless title = options.delete('title') or id = options.delete('id') or tag.locals.poll
      current_poll = Poll.find_current
      raise TagError, "'title' attribute required" unless current_poll
    end
    current_poll || tag.locals.poll || Poll.find_by_title(title) || Poll.find(id)
  end

  def find_options(tag)
    options = {}

    options[:page] = tag.attr['page'] || @request.path[/^#{Regexp.quote(tag.locals.page.url)}#{Regexp.quote(PollsExtension::UrlCache)}(\d+)\/?$/, 1]
    options[:per_page] = (tag.attr['per_page'] || 10).to_i
    raise TagError.new('the per_page attribute of the polls tag must be a positive integer') unless options[:per_page] > 0
    by = tag.attr['by'] || 'title'
    order = tag.attr['order'] || 'asc'
    order_string = ''
    if Poll.new.attributes.keys.include?(by)
      order_string << by
    else
      raise TagError.new('the by attribute of the polls tag must specify a valid field name')
    end
    if order =~ /^(a|de)sc$/i
      order_string << " #{order.upcase}"
    else
      raise TagError.new('the order attribute of the polls tag must be either "asc" or "desc"')
    end
    options[:order] = order_string

    # Exclude polls with null `by' values as well as any future polls and,
    # if it exists, the current poll unless it is specifically included.
    options[:conditions] = [ "#{by} IS NOT NULL AND COALESCE(start_date,?) <= ?",
                             Date.civil(1900,1,1), Date.today ]
    unless tag.attr['show_current'] == 'true'
      if current_poll = Poll.find_current
        options[:conditions].first << ' AND id <> ?'
        options[:conditions] << current_poll.id
      end
    end

    options
  end

end
