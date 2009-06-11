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
      @page.should_receive(:url).and_return('/')
      Page.should_receive(:find).with(duck_type(:to_i)).and_return(@page)
    end

    describe 'poll has not been previously submitted' do

      before :each do
        @poll = mock_model(Poll, :id => 42)
        Poll.should_receive(:find).with(duck_type(:to_i)).and_return(@poll)
        @poll.should_receive(:submit_response).with(an_instance_of(Option))
        @option = mock_model(Option)
        Option.should_receive(:find).with(duck_type(:to_i)).and_return(@option)
      end

      describe 'a current poll does not exist' do

        before :each do
          Poll.should_receive(:find_current).with(no_args()).and_return(nil)
        end

        it 'should not cache the response' do
          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          response.headers['Cache-Control'].should eql('no-cache')
        end

        it 'should instantiate the list of submitted polls with the poll ID' do
          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          session[:submitted_polls].should eql([@poll.id])
        end

        it 'should add the poll to the list of submitted polls' do
          session[:submitted_polls] = [@poll.id - 1]
          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          session[:submitted_polls].should eql([@poll.id - 1, @poll.id])
        end

      end

      describe 'a current poll exists' do

        before :each do
          @current_poll = mock_model(Poll, :id => @poll.id)
          Poll.should_receive(:find_current).with(no_args()).and_return(@current_poll)
        end

        it 'should instantiate the list of submitted polls with the poll ID' do
          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          session[:submitted_polls].should eql([@poll.id])
        end

      end

    end

    describe 'poll has been previously submitted' do

      before :each do
        @poll = mock_model(Poll, :id => 42)
        Poll.should_receive(:find).with(duck_type(:to_i)).and_return(@poll)
        @poll.should_not_receive(:submit_response)
        Option.should_not_receive(:find)
        session[:submitted_polls] = [@poll.id]
      end

      describe 'a current poll exists' do

        it 'should not add the poll to the list of submitted polls' do
          @current_poll = mock_model(Poll, :id => @poll.id)
          Poll.should_receive(:find_current).with(no_args()).and_return(@current_poll)

          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          session[:submitted_polls].should eql([@poll.id])
        end

      end

      describe 'a current poll does not exist' do

        it 'should not add the poll to the list of submitted polls' do
          Poll.should_receive(:find_current).with(no_args()).and_return(nil)

          post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
          session[:submitted_polls].should eql([@poll.id])
        end

      end

    end

    describe 'poll is out of date' do

      it 'should not alter a past poll' do
        @poll = mock_model(Poll, :id => 42)
        Poll.should_receive(:find).with(duck_type(:to_i)).and_return(@poll)
        @poll.should_not_receive(:submit_response)
        @current_poll = mock_model(Poll, :id => @poll.id + 1)
        Poll.should_receive(:find_current).with(no_args()).and_return(@current_poll)
        @current_poll.should_not_receive(:submit_response)
        Option.should_not_receive(:find)

        post :create, :page_id => @page.id, :poll_id => @poll.id.to_s, :response_id => '111'
      end

    end

  end

end
