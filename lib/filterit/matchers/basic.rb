require 'filterit/matcher'

module FilterIt

  module Matchers

    class BasicMatchers < FilterIt::Matchers::Base

      register_matcher :requires
      register_matcher :optional

      def requires(name, opts=nil, &block)
        raise FilterIt::Filter::InvalidEntry unless has_value_for(name)
        current_data = get_data(name)
        if opts.is_a?(Hash)
          helpers = @context.helpers
          for m,options in opts
            options = [options] unless options.is_a?(Array)
            out = helpers.send(m, current_data, *options)
            if out.nil?
              raise FilterIt::Filter::InvalidEntry
            else
              current_data = out
            end
          end
        end
        set_data(name, current_data)
      end

      def optional(name, opts=nil, &block)
        begin
          requires(name, opts, &block)
        rescue FilterIt::Filter::InvalidEntry => e
          @context.final_data.delete(find_key(name)) if @context.final_data.respond_to?(:delete)
        end
      end

    end

  end

end