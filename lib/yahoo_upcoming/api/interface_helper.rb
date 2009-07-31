module YahooUpcoming
  module Api
    module InterfaceHelper
      def initialize(intf)
        @intf = intf
      end

      def http_do(http_method, options = {})
        method = "#{namespace}.#{options.delete(:method)}"
        result = @intf.send(http_method, options.merge(:method => method))
        rsp = result.at('rsp')

        status, version = rsp['stat'], rsp['version']

        unless status == 'ok'
          message = rsp.at('error')['msg']
          raise Fail.new method, options, status, version, message
        end

        rsp
      end

      def get(options = {})
        http_do(:get, options)
      end

      def post(options = {})
        http_do(:post, options)
      end

      # A toy...
      # Tries to calculate the method name you want by camelizing it and doing
      # a get.
      def method_missing(name, *args)
        options = args.first
        options = {} unless options.kind_of?(Hash)
        method_name = toCamel(name)
        get(options.merge(:method => method_name))
      end

      # generate a namespace (event, user, etc) from the current class name
      def namespace
        @intf_namespace ||= self.class.name.split('::').last.downcase
      end

      # a convention to represent rising camel not activesupports camelize!
      def toCamel(name)
        parts = name.to_s.split('_')
        first = parts.shift
        parts.map! { |part| part.capitalize }
        first + parts.join
      end
    end
  end
end