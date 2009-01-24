module Admin::PollsHelper
  def admin_poll_title(poll)
    if poll.is_active?
      "<strong>#{poll.title}</strong>"
    else
      poll.title
    end
  end
end
