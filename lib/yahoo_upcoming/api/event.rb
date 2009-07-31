module YahooUpcoming
  module Api
    class Event
      include InterfaceHelper

      # An example...
      def search(optionals = {:search_text => ''})
        get optionals.merge(:method => 'search')
      end

      # API Example:
      # Convention is: required fields are args!
      #
      # name (Required)
      # The name of the event.
      # 
      # venue_id (Numeric, Required)
      # The venue_id of the event. To get a venue_id, try the venue.* series of functions.
      # 
      # category_id (Numeric, Required)
      # The category_id of the event. To get a category_id, try the category.* series of functions.
      # 
      # start_date (YYYY-MM-DD, Required)
      # The start date of the event, formatted as YYYY-MM-DD.
      def add(name, venue_id, category_id, start_date, optionals = {})
        post optionals.merge(
          :name        => name,
          :venue_id    => venue_id,
          :category_id => category_id,
          :start_date  => start_date
        )
      end
    end
  end
end