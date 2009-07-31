module YahooUpcoming
  module Api
    class Auth
      include InterfaceHelper

      def get_token
        tok = get(:method => 'getToken').at('token')
        @intf.authed! tok['token']
        tok.attributes
      end

      def check_token
        get(:method => 'checkToken').at('token').attributes
      end
    end
  end
end