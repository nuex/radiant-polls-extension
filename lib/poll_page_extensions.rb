module PollPageExtensions
  def self.included(base)
    base.class_eval do
      def cache=(value)
        @cache_page = value
      end
      def cache?
        @cache_page.nil? ? true : @cache_page
      end
    end
  end
end
