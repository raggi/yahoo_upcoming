module YahooUpcoming

  autoload :Api, 'yahoo_upcoming/api'
  autoload :MiniHttp, 'yahoo_upcoming/mini_http'
  autoload :Interface, 'yahoo_upcoming/interface'
  autoload :Comms, 'yahoo_upcoming/comms'
  autoload :Console, 'yahoo_upcoming/console'

  BASE_URI = "http://upcoming.yahooapis.com/services/rest/"

  # Convenience, see Interface.new
  def self.new(api_key, frob, token = nil, transport = transport)
    Interface.new(api_key, frob, token, transport)
  end

  # A transport singleton, for convenience. You can create interfaces with
  # other transports, however, using the defaults will re-use a single http
  # connection as much as possible, for all Interface instances.
  def self.transport
    @transport ||= MiniHttp.new(BASE_URI)
  end

  def self.irb(api_key, frob)
    upcoming = YahooUpcoming.new(api_key, frob)
    puts "You're inside an Upcoming interface instance..."
    puts "  example: event.search :search_text => 'bbc'"
    Console.start upcoming
  end

end