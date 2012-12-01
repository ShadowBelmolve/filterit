require 'filterit/matcher'

module FilterIt

  module Matchers

    class InheritMatcher < FilterIt::Matchers::Base

      register_matcher :inherit, :inherit_matcher

      def inherit_matcher(name, *contexts)
        if contexts.is_a?(Array) and contexts.length == 1 and contexts[0].is_a?(Array)
          contexts = contexts[0] 
        end
        (self.final_data ||= {}).merge!(FilterIt.run_filter(data, name, contexts))
      end

    end

  end

end