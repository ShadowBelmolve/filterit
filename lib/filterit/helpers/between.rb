require 'filterit/helper'

module FilterIt

  module Helpers

    class BetweenHelper < FilterIt::Helpers::Base

      register_helper :between

      def between(data, range1, range2=nil)
        if range1.is_a?(Range)
          range = range1
        else
          range = range1..range2
        end
        range.include?(data) ? data : nil
      end

    end

  end

end