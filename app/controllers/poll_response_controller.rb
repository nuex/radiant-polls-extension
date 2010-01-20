class PollResponseController < ApplicationController
  no_login_required
  skip_before_filter :verify_authenticity_token

  def create
    @page = Page.find(params[:page_id])
    @page.request, @page.response = request, response

    poll = Poll.find(params[:poll_id])
    current_poll = Poll.find_current
    session[:submitted_polls] = [] unless session[:submitted_polls]
    # If the poll has not been submitted and either no current_poll exists or the submitted poll is the current poll
    if !session[:submitted_polls].include?(poll.id) && (!current_poll || current_poll.id == poll.id)
      expires_now

      session[:submitted_polls] << poll.id

      poll_response = Option.find(params[:response_id])
      poll.submit_response(poll_response)
    end

    # assign the session to the current page so we can
    # pass it off to our radius tags
    @page.submitted_polls = session[:submitted_polls]

    redirect_to @page.url
  end

end
