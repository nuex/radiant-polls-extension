module PollTags
  include Radiant::Taggable

  class TagError < StandardError; end

  desc %{
    Selects the active poll.

    *Usage:*
    <pre><code><r:poll [title="poll_title"]>...</r:poll></code></pre>
  }
  tag 'poll' do |tag|
    options = tag.attr.dup
    tag.locals.page.cache = false
    tag.locals.poll = find_poll(tag, options)
    tag.expand
  end

  desc %{
    Expands inner tags if the poll has not been submitted yet.

    *Usage:*
    <pre><code><r:poll:unless_submitted title="My Poll">...</r:poll:unless_submitted></code></pre>

  }
  tag 'poll:unless_submitted' do |tag|
    options = tag.attr.dup
    poll = tag.locals.poll = find_poll(tag, options)
    tag.expand unless tag.locals.page.submitted_polls && tag.locals.page.submitted_polls.include?(poll.id)
  end

  desc %{
    Expands inner tags if the poll has been submitted.

    *Usage:*
    <pre><code><r:poll:unless_submitted title="My Poll">...</r:poll:unless_submitted></code></pre>

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
    <pre><code><r:poll title="My Poll"><r:form>...</r:form></r:poll></pre></code>
  }
  tag 'poll:form' do |tag|
    options = tag.attr.dup
    tag.locals.poll = find_poll(tag, options)
    poll = tag.locals.poll
    result = %Q{
      <form action="/pages/#{tag.locals.page.id}/poll_response" method="post" id="poll_form">
        #{tag.expand}
        <input type="hidden" name="poll_id" value="#{tag.locals.poll.id}" />
      </form>
    }
  end

  desc %{
    A container for options.
  }
  tag 'poll:options' do |tag|
    tag.expand
  end

  desc %{
    Iterate through each poll option.

    *Usage:*
    <pre><code><r:options:each>...</r:options:each></code></pre>
  }
  tag 'poll:options:each' do |tag|
    result = []
    options = tag.locals.poll.options
    tag.locals.options = options
    options.each do |option|
      tag.locals.option = option
      result << tag.expand
    end
    result
  end

  desc %{
    Show the poll option radio button input type.

    *Usage:*
    <pre><code><r:poll:form title="My Poll"><r:form><r:options:each><r:input /><r:title /></r:options:each></r:poll:form></code></pre>
  }
  tag 'poll:options:input' do |tag|
    option = tag.locals.option
    %{<input type="radio" name="response_id" value="#{option.id}" />}
  end

  desc %{
    Show the poll option title.

    *Usage:*
    <pre><code><r:poll:form title="My Poll"><r:options:each><r:title /></r:options:each></r:poll:form></code></pre>
  }
  tag 'poll:options:title' do |tag|
    tag.locals.option.title
  end

  desc %{
    Show a poll form submit button.

    *Usage:*
    <pre><code><r:poll:form title="My Poll"><r:options:each><r:input /><r:text /></r:options:each><r:submit [value="Go!"] /></r:poll:form></code></pre>
  }
  tag 'poll:submit' do |tag|
    options = tag.attr.dup
    options[:value] = 'Submit' unless options[:value]
    %{<input type="submit" name="poll[submit]" value="#{options[:value]}" />}
  end

  desc %{
    Show percentage of responses for a particular option.

    *Usage:*
    <pre><code><r:poll title="My Poll"><r:options:each><r:title /> <r:percent_responses /></r:options:each></r:poll></code></pre>
  }
  tag 'options:percent_responses' do |tag|
    tag.locals.option.response_percentage
  end

  desc %{
    Show count of responses for a particular option.

    *Usage:*
    <pre><code><r:poll title="My Poll"><r:options:each><r:title /> <r:number_responded /></r:options:each></r:poll></code></pre>
  }
  tag 'options:number_responses' do |tag|
    tag.locals.option.response_count
  end

  desc %{
    Show total number of visitors that responded.

    *Usage:*
    <pre><code><r:poll title="My Poll"><r:total_responded /></r:poll></code></pre>
  }
  tag 'poll:total_responses' do |tag|
    tag.locals.poll.response_count
  end

  tag 'poll_test' do |tag|
    "#{tag.locals.page.request.cookies.inspect}"
  end

  private

  def find_poll(tag, options)
    raise TagError, "'title' attribute required" unless title = options.delete('title') or id = options.delete('id') or tag.locals.poll
    tag.locals.poll || Poll.find_by_title(title) || Poll.find(id)
  end
  
end
