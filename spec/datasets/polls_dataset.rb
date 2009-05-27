class PollsDataset < Dataset::Base

  def load
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
