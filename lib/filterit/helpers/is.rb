require 'filterit/helper'

FilterIt::Helpers.register_helper(:is) do |data, *classes|
  classes.flatten!
  if classes.include?(data) or classes.include?(data.class)
    next data
  else
    out = classes.each do |c|
      break data if data.is_a?(c)
    end
    next out if out != classes
  end
  nil
end