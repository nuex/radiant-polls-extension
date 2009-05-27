class PollsDataset < Dataset::Base

  def load
    create_poll 'Next Poll', :start_date => Date.today + 1.week do
      create_option 'Oceania'
      create_option 'Eastasia'
      create_option 'Eurasia'
    end
    create_poll 'Current Poll', :start_date => Date.today do
      create_option 'Foo'
      create_option 'Bar'
      create_option 'Baz'
    end
    create_poll 'Previous Poll', :start_date => Date.today - 1.week do
      create_option 'Yes', 1
      create_option 'No', 2
      create_option 'Maybe', 3
    end
    create_poll 'Test Poll' do
      create_option 'One', 0
      create_option 'Two', 4
      create_option 'Three', 6
    end
  end

  helpers do
    def create_poll(title, attributes = {})
      poll = create_model(:poll, title, attributes.update(:title => title))
      if block_given?
        @current_poll = poll
        yield
      end
    end

    def create_option(title, responses = 0, attributes = {})
      option = create_model(:option, title, attributes.update(:title => title, :poll_id => @current_poll.id))
      responses.times do
        @current_poll.submit_response option
      end
    end
  end

end
