require "filterit/version"
require "filterit/filter"
require 'filterit/matchers/basic'
require 'filterit/matchers/inherit'
require 'filterit/helpers/is'
require 'filterit/helpers/between'
require 'filterit/helpers/in'
require 'filterit/helpers/inherit'

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

  def self.run_filter(data, name=nil, contexts=nil, return_ctx=nil, &block)
    if block_given?
      return_ctx = contexts
      contexts = name || []
      contexts = [contexts] unless contexts.is_a?(Array)
      ctx = FilterIt::Filter::Context.new(*contexts)
      ctx.run(data, &block)
      if return_ctx
        ctx
      else
        ctx.final_data
      end
    else
      filter = get_filter(name)
      filter.run(data, contexts||[], return_ctx)
    end
    
  end

end
