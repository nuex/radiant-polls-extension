class Option < ActiveRecord::Base
  belongs_to :poll
  validates_presence_of :title
  before_create :set_defaults

  # return the percentage of responses this
  # option has
  def response_percentage
    return 0 unless self.poll.response_count >= 1
    sprintf("%0.1f", (self.response_count / self.poll.response_count.to_f) * 100.0)
  end

  def should_destroy?
    should_destroy.to_i == 1
  end

  private

  def set_defaults
    self.response_count = 0
  end
end
