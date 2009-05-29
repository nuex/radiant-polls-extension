require File.dirname(__FILE__) + '/../spec_helper'

describe 'Poll Tags' do
  dataset :pages

  before do
    options = { Option.new(:title => 'One') => 0,
                Option.new(:title => 'Two') => 4,
                Option.new(:title => 'Three') => 6 }
    poll = Poll.create(:title => 'Test Poll', :options => options.keys)
    options.each do |option, response_count|
      response_count.times do
        poll.submit_response option
      end
    end
    Poll.create(:title => 'Current Poll',
                :start_date => Date.today,
                :options => [ Option.new(:title => 'Foo'),
                              Option.new(:title => 'Bar'),
                              Option.new(:title => 'Baz') ])
  end

  describe '<r:poll> with no start dates' do

    before do
      Poll.update_all('start_date = NULL', 'start_date IS NOT NULL')
    end

    it 'should not accept an empty tag' do
      tag = %{<r:poll/>}

      pages(:home).should render(tag).with_error("'title' attribute required")
    end

  end

  describe '<r:poll>' do

    it 'should accept an empty tag and generate no output' do
      tag = %{<r:poll/>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept a title tag and generate no output' do
      tag = %{<r:poll title="Test Poll"/>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept an id tag and generate no output' do
      tag = %{<r:poll id="#{Poll.find(:first).id}"/>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:title>' do

    it 'should show the title of the specified poll' do
      title = 'Test Poll'
      tag = %{<r:poll title="#{title}"><r:title/></r:poll>}

      pages(:home).should render(tag).as(title)
    end

    it 'should show the title of the current poll' do
      title = 'Current Poll'
      tag = %{<r:poll><r:title/></r:poll>}

      pages(:home).should render(tag).as(title)
    end

  end

  describe '<r:poll:form>' do

    it 'should generate an empty form' do
      tag = %{<r:poll title="Test Poll"><r:form/></r:poll>'}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<input type="hidden"[^>]*>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options>' do

    it 'should generate an empty form' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<input type="hidden"[^>]*>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each>' do

    it 'should generate an empty form' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<input type="hidden"[^>]*>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each:input>' do

    it 'should generate a form with input options' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each><r:input/></r:options:each></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*(<input type="radio"[^>]*>\s*){3}<input type="hidden"[^>]*>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each:title>' do

    it 'should show the option titles' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each><r:input/><r:title/></r:options:each></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*(<input type="radio"[^>]*>\s*(One|Two|Three)\s*){3}<input type="hidden"[^>]*>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:options:each:title>' do

    it 'should show the option titles in random order' do
      tag = %{<r:poll title="Test Poll"><r:options order="rand"><r:each><r:title/></r:each></r:options></r:poll>}
      expected = /OneTwoThree|OneThreeTwo|TwoOneThree|TwoThreeOne|ThreeOneTwo|ThreeTwoOne/

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:options:each:number_responses>' do

    it 'should show the response numbers in descending order' do
      tag = %{<r:poll title="Test Poll"><r:options order="desc"><r:each><p><r:number_responses/></p></r:each></r:options></r:poll>}
      expected = '<p>6</p><p>4</p><p>0</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:percent_responses>' do

    it 'should show the response percentages in ascending order' do
      tag = %{<r:poll title="Test Poll"><r:options order="asc"><r:each><p><r:percent_responses/></p></r:each></r:options></r:poll>}
      expected = '<p>0.0</p><p>40.0</p><p>60.0</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

end
