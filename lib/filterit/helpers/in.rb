require 'filterit/helper'

module FilterIt

  module Helpers

    class InHelper < FilterIt::Helpers::Base

      register_helper :in

      def in(data, *list)
        list.flatten.include?(data) ? data : nil
      end

    end

  end

end