module FilterIt

  module Helpers

    HELPERS = Class.new

    def self.register_helper(name, method_name=nil, &block)
      use_block = block_given?
      this = self
      HELPERS.define_singleton_method(name) do |*args, &arg_block|
        if use_block
          block.call(*args, &arg_block)
        else
          this.send(method_name||name, *args, &arg_block)
        end
      end
    end

  end

end