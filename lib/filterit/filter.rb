module FilterIt

  class Filter

    class InvalidEntry < ArgumentError; end

    def initialize(opts={}, &block)
      @block = block
      #@opts = opts
    end

    def run(data, contexts=[], return_ctx=false)
      contexts ||= []
      contexts = [contexts] unless contexts.is_a?(Array)
      ctx = Context.new(*contexts)
      ctx.run(data, &@block)
      if return_ctx
        ctx
      else
        ctx.final_data
      end
    end

    class Context

      attr_reader :data
      attr_accessor :final_data
      attr_accessor :last_run_value

      def initialize(*contexts)
        @contexts = []
        @context_values = {}
        @context_procs = {}
        for ctx in contexts
          if ctx.is_a?(Hash)
            ctx.each do |k,v|
              key = k.to_s
              @context_values[key] = v

              define_singleton_method(key) do
                @context_values[key]
              end

              #instance_eval <<-EOF, __FILE__, __LINE__+1
              #  def #{key}
              #    @context_values[#{key.inspect}]
              #  end
              #EOF
            end
          else
            @contexts << ctx
          end
        end
      end

      def method_missing(name, *args, &block)
        for ctx in @contexts
          begin
            out = ctx.send(name, *args, &block)
          rescue NoMethodError => e
            next
          end
          key = name.to_s
          @context_procs[key] = ctx
          define_singleton_method(key) do |*args_inner,&block_inner|
            @context_procs[key].send(key, *args_inner, &block_inner)
          end
          #instance_eval <<-EOF, __FILE__, __LINE__+1
          #    def #{key}(*args, &block)
          #      @context_procs[#{key.inspect}].send(#{key.inspect}, *args, block)
          #    end
          #EOF
          return out
        end
        super
      end

      def run(data = nil, &block)
        @data = data
        @final_data = nil
        @last_run_value = block.arity == 1 ? block.call(self) : instance_eval(&block)
      end

      def helpers
        FilterIt::Helpers::HELPERS
      end

    end

  end

end
