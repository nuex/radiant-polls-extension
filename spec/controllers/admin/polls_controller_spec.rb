require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PollsController do
  dataset :users

  before(:each) do
    login_as :existing
  end

  describe "index" do
    it "should show the index template" do
      get :index
      response.should render_template('admin/polls/index')
    end
  end
end
