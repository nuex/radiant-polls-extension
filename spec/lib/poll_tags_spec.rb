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

  describe 'with no polls' do

    before do
      Poll.delete_all
    end

    describe '<r:poll>' do

      it 'should accept a bare tag and generate an error message' do
        tag = %{<r:poll/>}
        expected = 'No polls found'

        pages(:home).should render(tag).as(expected)
      end

      it 'should accept a title attribute and generate an error message' do
        tag = %{<r:poll title="Test Poll"/>}
        expected = 'No polls found'

        pages(:home).should render(tag).as(expected)
      end

    end

    describe '<r:poll:title>' do

      it 'should generate an error message and no inner content' do
        tag = %{<r:poll><h2><r:title/></h2></r:poll>}
        expected = 'No polls found'

        pages(:home).should render(tag).as(expected)
      end

    end

  end

  describe '<r:poll>' do

    it 'should accept an empty tag and generate no output' do
      tag = %{<r:poll/>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept a title attribute and generate no output' do
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
      tag = %{<r:poll title="Test Poll"><r:form/></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:submit>' do

    it 'should generate an empty form with a default submit button' do
      tag = %{<r:poll title="Test Poll"><r:form><r:submit/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*<input type="submit".*?value="Submit"[^>]*>\s*<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

    it 'should generate an empty form with a custom submit button' do
      tag = %{<r:poll title="Test Poll"><r:form><r:submit value="Vote"/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*<input type="submit".*?value="Vote"[^>]*>\s*<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options>' do

    it 'should generate an empty form' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each>' do

    it 'should generate an empty form' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each/></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each:input>' do

    it 'should generate a form with input options' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each><r:input/></r:options:each></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*(<input type="radio"[^>]*>\s*){3}<input type="hidden"[^>]*>\s*</div>\s*</form>}

      pages(:home).should render(tag).matching(expected)
    end

  end

  describe '<r:poll:form:options:each:title>' do

    it 'should show the option titles' do
      tag = %{<r:poll title="Test Poll"><r:form><r:options:each><r:input/><r:title/></r:options:each></r:form></r:poll>}
      expected = %r{<form action="/pages/\d+/poll_response" method="post" id="poll_form">\s*<div>\s*(<input type="radio"[^>]*>\s*(One|Two|Three)\s*){3}<input type="hidden"[^>]*>\s*</div>\s*</form>}

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

  describe '<r:poll:options:each:if_first>' do

    it 'should render inner tags only if the current context is the first option' do
      tag = %{<r:poll title="Test Poll"><ul><r:options order="desc"><r:each><li<r:if_first> class="first"</r:if_first>><r:percent_responses /></li></r:each></r:options></ul></r:poll>}
      expected = '<ul><li class="first">60.0</li><li>40.0</li><li>0.0</li></ul>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:if_last>' do

    it 'should render inner tags only if the current context is the last option' do
      tag = %{<r:poll title="Test Poll"><ul><r:options order="desc"><r:each><li<r:if_last> class="last"</r:if_last>><r:percent_responses /></li></r:each></r:options></ul></r:poll>}
      expected = '<ul><li>60.0</li><li>40.0</li><li class="last">0.0</li></ul>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:unless_first>' do

    it 'should render inner tags only unless the current context is the first option' do
      tag = %{<r:poll title="Test Poll"><r:options order="desc"><r:each><r:unless_first>,</r:unless_first><r:percent_responses /></r:each></r:options></r:poll>}
      expected = '60.0,40.0,0.0'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:poll:options:each:unless_last>' do

    it 'should render inner tags only unless the current context is the last option' do
      tag = %{<r:poll title="Test Poll"><r:options order="desc"><r:each><r:percent_responses /><r:unless_last>,</r:unless_last></r:each></r:options></r:poll>}
      expected = '60.0,40.0,0.0'

      pages(:home).should render(tag).as(expected)
    end

  end

  ##
  ## Test poll archives
  ##

  describe '<r:polls>' do

    it 'should accept an empty tag and generate no output' do
      tag = %{<r:polls/>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept valid options and generate no output' do
      tag = %{<r:polls per_page="10" by="title" order="asc" show_current="false" />}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    describe 'with per_page option' do

      it 'should not accept a non-positive integer and generate an error' do
        tag = %{<r:polls per_page="-5" />}

        pages(:home).should render(tag).with_error('the per_page attribute of the polls tag must be a positive integer')
      end

      it 'should not accept a non-integer value and generate an error' do
        tag = %{<r:polls per_page="no" />}

        pages(:home).should render(tag).with_error('the per_page attribute of the polls tag must be a positive integer')
      end

    end

    describe 'with by option' do

      it 'should not accept an invalid field name and generate an error' do
        tag = %{<r:polls by="foobar"/>}

        pages(:home).should render(tag).with_error('the by attribute of the polls tag must specify a valid field name')
      end

    end

    describe 'with order option' do

      it 'should accept "asc" and generate no output' do
        tag = %{<r:polls order="asc"/>}
        expected = ''

        pages(:home).should render(tag).as(expected)
      end

      it 'should accept "desc" and generate no output' do
        tag = %{<r:polls order="desc"/>}
        expected = ''

        pages(:home).should render(tag).as(expected)
      end

      it 'should not accept a value other than "asc" or "desc" and generate an error' do
        tag = %{<r:polls order="xxx"/>}

        pages(:home).should render(tag).with_error('the order attribute of the polls tag must be either "asc" or "desc"')
      end

    end

    describe 'with no polls' do

      before do
        Poll.delete_all
      end

      it 'should accept a bare tag and generate an error message' do
        tag = %{<r:polls/>}
        expected = 'No polls found'

        pages(:home).should render(tag).as(expected)
      end

    end

  end

  describe '<r:polls:each>' do

    it 'should generate no output' do
      tag = %{<r:polls><r:each></r:each></r:polls>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:polls:each:poll>' do

    it 'should generate no output' do
      tag = %{<r:polls><r:each><r:poll/></r:each></r:polls>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:polls:each:poll:title>' do

    before do
      # Create a future poll that should never appear in any results
      Poll.create(:title => 'Next Poll', :start_date => Date.today + 1.week)
    end

    it 'should generate an ordered list of poll titles in descending order' do
      tag = %{<r:polls order="desc" show_current="true"><r:each><r:poll><p><r:title/></p></r:poll></r:each></r:polls>}
      expected = '<p>Test Poll</p><p>Current Poll</p>'

      pages(:home).should render(tag).as(expected)
    end

    it 'should generate a list of the one poll that has a non-future start date' do
      tag = %{<r:polls by="start_date" show_current="true"><r:each><r:poll><p><r:title/></p></r:poll></r:each></r:polls>}
      expected = '<p>Current Poll</p>'

      pages(:home).should render(tag).as(expected)
    end

    it 'should generate an ordered list of poll titles in descending order by start date' do
      poll = Poll.find_by_title('Test Poll').update_attribute(:start_date, Date.today - 1.week)
      tag = %{<r:polls by="start_date" order="desc" show_current="true"><r:each><r:poll><p><r:title/></p></r:poll></r:each></r:polls>}
      expected = '<p>Current Poll</p><p>Test Poll</p>'

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:polls:each:poll:options:title>' do

    it 'should generate a list containing the current poll with its options' do
      tag = %{<r:polls by="start_date" show_current="true"><r:each><r:poll><p><r:title/></p><r:options order="desc"><r:each><p><r:title/></p></r:each></r:options></r:poll></r:each></r:polls>}
      expected = '<p>Current Poll</p><p>Foo</p><p>Bar</p><p>Baz</p>'

      pages(:home).should render(tag).as(expected)
    end

    it 'should generate no output when sorting by start date and excluding the current poll' do
      tag = %{<r:polls by="start_date"><r:each><r:poll><p><r:title/></p><r:options order="desc"><r:each><p><r:title/></p></r:each></r:options></r:poll></r:each></r:polls>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:polls:pages>' do

    describe 'with less than per_page polls' do

      it 'should not generate pagination links' do
        tag = %{<r:polls by="title"><r:pages/></r:polls>}
        expected = ''

        pages(:home).should render(tag).as(expected)
      end

    end

    describe 'with more than per_page polls' do

      before do
        (1..20).each do |i|
          Poll.create(:title => "Poll #{i}",
                      :start_date => Date.today - i.weeks,
                      :options => [ Option.new(:title => "Foo #{i}"),
                                    Option.new(:title => "Bar #{i}"),
                                    Option.new(:title => "Baz #{i}") ])
        end
      end

      it 'should generate pagination links' do
        tag = %{<r:polls per_page="5" by="start_date" order="desc"><r:pages/></r:polls>}
        expected = %r{<span class="current">1</span>}

        pages(:home).should render(tag).matching(expected)
      end

  end

  end

end
