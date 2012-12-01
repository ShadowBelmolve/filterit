require 'filterit/helper'

FilterIt::Helpers.register_helper(:between) do |data, range1, range2=nil|
  if range1.is_a?(Range)
    range = range1
  else
    range = range1..range2
  end
  range.include?(data) ? data : nil
end