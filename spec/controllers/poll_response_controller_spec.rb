require File.dirname(__FILE__) + '/../spec_helper'

describe PollResponseController do

  describe 'routing' do

    it 'should route to the index action' do
      params_from(:get, '/pages/1/poll_response').should == { :controller => 'poll_response', :action => 'index', :page_id => '1' }
    end

    it 'should route to the create action' do
      params_from(:post, '/pages/1/poll_response').should == { :controller => 'poll_response', :action => 'create', :page_id => '1' }
    end

  end

  describe :create do

    before :each do
      @page = mock_model(Page, :id => 1)
      @page.should_receive(:request=).with(an_instance_of(ActionController::TestRequest))
      @page.should_receive(:response=).with(an_instance_of(ActionController::TestResponse))
      @page.should_receive(:submitted_polls=).with(an_instance_of(Array))
      Page.should_receive(:find).with(duck_type(:to_i)).and_return(@page)

      @poll = mock_model(Poll, :id => 42)
      Poll.should_receive(:find).with(duck_type(:to_i)).and_return(@poll)

      @option = mock_model(Option)
    end

    it 'should not cache the response' do
      Option.should_receive(:find).with(duck_type(:to_i)).and_return(@option)
      @poll.should_receive(:submit_response).with(an_instance_of(Option))
      @page.should_receive(:url).twice.and_return('/')

      post :create, :page_id => '1', :poll_id => '42', :response_id => '111'
      response.headers['Cache-Control'].should eql('no-cache')
    end

    it 'should instantiate the list of submitted polls with the poll ID' do
      Option.should_receive(:find).with(duck_type(:to_i)).and_return(@option)
      @poll.should_receive(:submit_response).with(an_instance_of(Option))
      @page.should_receive(:url).twice.and_return('/')

      post :create, :page_id => '1', :poll_id => '42', :response_id => '111'
      session[:submitted_polls].should eql([42])
    end

    it 'should add the poll to the list of submitted polls' do
      Option.should_receive(:find).with(duck_type(:to_i)).and_return(@option)
      @poll.should_receive(:submit_response).with(an_instance_of(Option))
      @page.should_receive(:url).twice.and_return('/')

      session[:submitted_polls] = [41]
      post :create, :page_id => '1', :poll_id => '42', :response_id => '111'
      session[:submitted_polls].should eql([41,42])
    end

    it 'should not add the poll to the list of submitted polls' do
      Option.should_not_receive(:find)
      @poll.should_not_receive(:submit_response)
      @page.should_receive(:url).once.and_return('/')

      session[:submitted_polls] = [42]
      post :create, :page_id => '1', :poll_id => '42', :response_id => '111'
      session[:submitted_polls].should eql([42])
    end

  end
end
