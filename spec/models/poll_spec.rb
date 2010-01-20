require File.dirname(__FILE__) + '/../spec_helper'

describe Poll do
  before(:each) do
    @poll = Poll.new(:title => 'Poll',
                     :start_date => Date.today,
                     :options => [ Option.new(:title => 'One'),
                                   Option.new(:title => 'Two') ])
  end

  it 'should be valid' do
    @poll.should be_valid
  end

  context 'validations' do

    it 'should require a title' do
      @poll.title = nil
      @poll.should_not be_valid
      @poll.errors.on(:title) == I18n.t('activerecord.errors.messages.blank')
    end

    it 'should not require a start date' do
      @poll.start_date = nil
      @poll.should be_valid
    end

    it 'should not accept a duplicate title' do
      @poll.save
      poll = Poll.new(:title => 'Poll',
                      :start_date => Date.today + 1.week,
                      :options => [ Option.new(:title => 'True'),
                                    Option.new(:title => 'False') ])
      poll.should_not be_valid
      poll.errors.on(:title) == I18n.t('activerecord.errors.messages.taken')
    end

    it 'should not accept a duplicate start date' do
      @poll.save
      poll = Poll.new(:title => 'New Poll',
                      :start_date => Date.today,
                      :options => [ Option.new(:title => 'True'),
                                    Option.new(:title => 'False') ])
      poll.should_not be_valid
      poll.errors.on(:start_time) == I18n.t('activerecord.errors.messages.taken')
    end

  end

end
