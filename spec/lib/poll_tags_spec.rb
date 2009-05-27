require File.dirname(__FILE__) + '/../spec_helper'

describe 'Poll Tags' do
  dataset :pages, :polls

  describe '<r:poll>' do

    it 'should not accept an empty tag' do
      tag = %{<r:poll/>}

      pages(:home).should render(tag).with_error("'title' attribute required")
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

    it 'should show the option titles' do
      tag = %{<r:poll title="Test Poll"><r:options:each><p><r:title/></p></r:options:each></r:poll>}
      expected = '<p>One</p><p>Two</p><p>Three</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:number_responses>' do

    it 'should show the response numbers' do
      tag = %{<r:poll title="Test Poll"><r:options:each><p><r:number_responses/></p></r:options:each></r:poll>}
      expected = '<p>0</p><p>4</p><p>6</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:percent_responses>' do

    it 'should show the response percentages' do
      tag = %{<r:poll title="Test Poll"><r:options:each><p><r:percent_responses/></p></r:options:each></r:poll>}
      expected = '<p>0.0</p><p>40.0</p><p>60.0</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

end
