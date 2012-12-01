module FilterIt

  module Matchers

    class Base

      def self.register_matcher(name, method_name=nil)
        this = self
        FilterIt::Filter::Context.send(:define_method, name) do |*args, &block|
          this.new(self).send(method_name||name, *args, &block)
        end
      end

      def initialize(context)
        @context = context
      end

      def data
        @context.data
      end

      def final_data
        @context.final_data
      end

      def final_data=(v)
        @context.final_data = v
      end

      def has_value_for(name)
        data[find_key(name)]
      end

      def find_key(name)
        if @context.data.has_key?(name)
          name
        else
          name.is_a?(String) ? name.to_sym : name.to_s
        end
      end

      def get_data(name)
        if has_value_for(name)
          data[find_key(name)]
        end
      end

      def set_data(name, value=nil)
        key = find_key(name)
        if value.nil?
          value = @context.data[key]
        end
        @context.final_data = {} unless @context.final_data.respond_to?(:[]=)
        @context.final_data[key] = value
      end

    end

  end

end