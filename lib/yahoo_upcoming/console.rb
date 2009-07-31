module YahooUpcoming
  module Console
    class << self; attr_accessor :instance; end

    def self.start(binding)
      require 'irb'
      old_args = ARGV.dup
      ARGV.replace []

      IRB.setup(nil)
      self.instance = IRB::Irb.new(IRB::WorkSpace.new(binding))

      @CONF = IRB.instance_variable_get(:@CONF)
      @CONF[:IRB_RC].call self.instance.context if @CONF[:IRB_RC]
      @CONF[:MAIN_CONTEXT] = self.instance.context
      @CONF[:PROMPT_MODE] = :SIMPLE

      catch(:IRB_EXIT) { self.instance.eval_input }
    ensure
      ARGV.replace old_args
      begin; catch(:IRB_EXIT) { irb_exit }; rescue Exception; end
    end
  end
end