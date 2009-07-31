begin
  require 'nokogiri'
rescue LoadError
  begin
    require 'hpricot'
  rescue LoadError
    raise LoadError, 'yahoo_upcoming requires either nokogiri or hpricot'
  end
end

module YahooUpcoming
  class Interface
    XML_PARSER = defined?(Nokogiri) ? Nokogiri : Hpricot
    
    attr_reader :options

    # An Interface provides an api to operate as a single user. You can also
    # later switch user by altering +:api_key+, +:frob+, and +:token+ in
    # +#options+. The final argument is a transport object that must conform
    # to the same API as +MiniHttp+.
    def initialize(api_key, frob, token = nil, comms = YahooUpcoming.transport)
      @options = {
        :api_key => api_key,
        :frob    => frob,
        :token   => token
      }
      @comms = comms
    end

    # Access to the 'auth' section of the api. See +Auth+.
    def auth
      @auth ||= Api::Auth.new(self)
    end

    # Access to the 'event' section of the api. See +Event+.
    # Example:
    #   interface.event.search :search_text => 'bbc'
    def event
      @event ||= Api::Event.new(self)
    end

    # another toy...
    def method_missing(name, *args)
      iv_name = "@#{name.to_s}"
      iv = instance_variable_get(iv_name)
      return iv if iv

      class_name = "Api::#{name.to_s.capitalize}"
      eval <<-EOF
      class #{class_name}
        include InterfaceHelper
      end
      EOF

      instance = self.class.const_get(class_name).new(self)
      instance_variable_set(iv_name, instance)
      instance
    end

    def auth!
      auth.get_token
    end

    def authed!(token)
      @options[:token] = token
    end

    def authed?
      @options[:token] && check_token
    end

    def get(options = {})
      XML_PARSER.XML(@comms.get(@options.merge(options)).body)
    end

    def post(options = {})
      XML_PARSER.XML(@comms.post(@options.merge(options)).body)
    end
  end
end