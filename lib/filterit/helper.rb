module FilterIt

  module Helpers

    HELPERS = Class.new

    class Base

      def self.register_helper(name, method_name=nil)
        this = self
        HELPERS.define_singleton_method(name) do |*args, &block|
          this.new.send(method_name||name, *args, &block)
        end
      end

    end

  end

end