module PollProcess
  def self.included(base)
    base.class_eval {
      alias_method_chain :process, :poll
      attr_accessor :submitted_polls
    }
  end

  def process_with_poll(request, response)
    # check the session and set the polls that 
    # have been submitted (if such a session exists)
    if response.session[:submitted_polls]
      self.submitted_polls = response.session[:submitted_polls]
    end
    process_without_poll(request, response)
  end
end
