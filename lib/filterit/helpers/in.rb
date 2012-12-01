require 'filterit/helper'

FilterIt::Helpers.register_helper(:in) do |data, *list|
  list.flatten.include?(data) ? data : nil
end