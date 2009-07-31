require 'yaml'

module YahooUpcoming
  module Api
    class Fail < Exception
      attr_accessor :method, :options, :status, :version, :msg
      def initialize(method, options, status, version, msg)
        @method, @options, @status, @version, @result = 
          method, options, status, version, result

        ed = YAML.dump(
          :method  => method,
          :options => options,
          :status  => status,
          :version => version,
          :message  => msg
        )

        super("#{msg}\n#{ed}")
      end
    end
  end
end