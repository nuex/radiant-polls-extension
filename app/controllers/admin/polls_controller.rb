class Admin::PollsController < ApplicationController
  def index
    @polls = Poll.find(:all)
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = Poll.create(params[:poll])
    flash[:notice] = "Poll '#{@poll.title}' Created"
    redirect_to :action => :index
  end

  def edit
    @poll = Poll.find(params[:id])
  end

  def update
    @poll = Poll.find(params[:id])
    if @poll.update_attributes(params[:poll])
      flash[:notice] = "Successfully updated '#{@poll.title}'."
      redirect_to :action => :index
    else
      render_action 'edit'
    end
  end

  def destroy
    Poll.destroy(params[:id])
    flash[:notice] = "Poll destroyed"
    redirect_to :action => :index
  end

  def clear_responses
    @poll = Poll.find(params[:id])
    @poll.clear_responses
    flash[:notice] = "Poll '#{@poll.title}' responses cleared."
    redirect_to :action => :index
  end
end
