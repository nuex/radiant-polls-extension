class Poll < ActiveRecord::Base
  has_many :options
  after_update :save_options
  validates_presence_of :title
  validates_associated :options
  before_create :set_defaults

  def option_attributes=(option_attributes)
    option_attributes.each do |attributes|
      if attributes[:id].blank?
        attributes[:response_count] = 0
        options.build(attributes)
      else
        option = options.detect { |a| a.id == attributes[:id].to_i }
        option.attributes = attributes
      end
    end
  end

  # submit a response to the poll and update
  # the response counts for the poll and the option
  def submit_response(option)
    option.update_attribute(:response_count, option.response_count + 1) 
    self.update_attribute(:response_count, self.response_count + 1)

    return true
  end

  # clear the number of the responses for the poll
  # and all of its options
  def clear_responses
    self.update_attribute(:response_count, 0)
    self.options.find(:all, :conditions => ["response_count >= 1"]).each do |option|
      option.update_attribute(:response_count, 0)
    end
  end

  private

  def save_options
    options.each do |option|
      if option.should_destroy?
        option.destroy
      else
        option.save(false)
      end
    end
  end

  def set_defaults
    self.response_count = 0
  end

end
