class Admin::PollsController < Admin::ResourceController
  model_class Poll

  def clear_responses
    if @poll = Poll.find(params[:id])
      @poll.clear_responses
      flash[:notice] = t('polls_controller.responses_cleared', :poll => @poll.title)
    end
    redirect_to :action => :index
  end

  protected

    def load_models
      # Order polls by descending date, then alphabetically by title
      self.models = model_class.all(:order => "COALESCE(start_date, '1900-01-01') DESC, title")
    end

end
