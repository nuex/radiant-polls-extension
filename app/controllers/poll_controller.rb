class PollController < ApplicationController
  no_login_required

  def respond
    @page = Page.find(params[:page])
    poll = Poll.find(params[:id])
    response = Option.find(params[:response_id])
    poll.submit_response(response)
    ResponseCache.instance.expire_response(@page.url)
    cookies['poll'] = params[:poll_id]
    redirect_to @page.url
  end
  
end
