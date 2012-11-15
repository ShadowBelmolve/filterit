require 'filterit/helper'

module FilterIt

  module Helpers

    class IsHelper < FilterIt::Helpers::Base

      register_helper :is

      def is(data, *classes)
        classes.flatten!
        if classes.include?(data) or classes.include?(data.class)
          return data
        else
          classes.each do |c|
            return data if data.is_a?(c)
          end
        end

        nil
      end

    end

  end

end