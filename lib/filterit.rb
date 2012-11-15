require "filterit/version"
require "filterit/filter"
require 'filterit/matchers/basic'
require 'filterit/helpers/is'
require 'filterit/helpers/between'
require 'filterit/helpers/in'

module FilterIt

  @filters = {}

  def self.register_filter(name, opts={}, &block)
    raise ArgumentError, 'no block given' unless block_given?
    raise ArgumentError, 'name cannot be nil' if name.nil?
    raise ArgumentError, 'name already in use' if @filters.include?(name)
    filter = FilterIt::Filter.new(opts, &block)
    @filters[name] = filter
  end

  def self.get_filter(name)
    @filters[name]
  end

end
