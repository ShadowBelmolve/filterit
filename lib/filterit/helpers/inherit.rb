require 'filterit/helper'

FilterIt::Helpers.register_helper(:inherit) do |data, name|
  FilterIt.run_filter(data, name)
end