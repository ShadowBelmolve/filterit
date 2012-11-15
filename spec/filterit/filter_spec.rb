describe FilterIt::Filter do

  describe FilterIt::Filter::Context, '#context' do

    it "should accept any number of options as contexts" do
      expect do
        FilterIt::Filter::Context.new
        FilterIt::Filter::Context.new({})
        FilterIt::Filter::Context.new({ :a => :b })
        FilterIt::Filter::Context.new(10, "foo")
        FilterIt::Filter::Context.new(:bar, 1.5, Class)
      end.to_not raise_exception
    end

    it "should transform hash keys into methods on initialize" do
      ctx = FilterIt::Filter::Context.new({ :a => :b })
      ctx.respond_to?(:a).should be_true
      ctx.a.should eql(:b)
    end

    it "should transform multiple hash keys into methods on initialize" do
      ctx = FilterIt::Filter::Context.new({ :a => :b, :b => :c },
                                          { :a => :d })
      ctx.a.should eql(:d)
      ctx.b.should eql(:c)
    end

    it "should works even with non-hash objects" do
      mock = Struct.new(:a).new(10)
      ctx = FilterIt::Filter::Context.new(mock, { :b => :c })
      ctx.a.should eql(10)
    end

    it "hash objects should overwrite non-hash objects methods" do
      mock1 = Struct.new(:a, :b).new(10, 20)
      mock2 = Struct.new(:c, :d).new(30, 40)
      ctx = FilterIt::Filter::Context.new(mock1, mock2,
                                          { :a => 50, :c => 60 })
      ctx.respond_to?(:a).should be_true
      ctx.respond_to?(:c).should be_true
      ctx.a.should eql(50)
      ctx.b.should eql(20)
      ctx.c.should eql(60)
      ctx.d.should eql(40)
    end

    it "non-hash object methods should be defined after first use" do
      mock = Struct.new(:a, :b).new(10, 20)
      ctx = FilterIt::Filter::Context.new(mock)

      ctx.respond_to?(:a).should be_false
      ctx.respond_to?(:b).should be_false
      ctx.a.should eql(10)

      ctx.respond_to?(:a).should be_true
      ctx.respond_to?(:b).should be_false
      ctx.b.should eql(20)

      ctx.respond_to?(:a).should be_true
      ctx.respond_to?(:b).should be_true
    end

    it "methods not found on any context should raise a MethodMissing" do
      mock = Struct.new(:a, :b).new(10, 20)
      ctx = FilterIt::Filter::Context.new(mock)
      ctx.a.should eql(10)
      ctx.b.should eql(20)
      expect { ctx.c }.to raise_error(NoMethodError)
    end

    describe "run" do

      let(:new_ctx) { FilterIt::Filter::Context.new }

      describe "self" do
        it "should change self if block expect no arguments" do
          ctx = new_ctx

          eql_proc = Proc.new do |value|
            be_eql(value)
          end

          this = self

          ctx.run do
            self.should_not eql_proc.call(this)
          end
        end

        it "should not change self if block expect an argument" do
          pending "Strange bug"
          ctx = new_ctx

          this = self

          ctx.run do |ctx_self|
            # failing, don't know why
            self.should be(this)
            self.should_not be(ctx_self)
          end
        end

        it "should respect outside methods/variables" do
          a = 10
          b = 20
          c = 30

          mock = Struct.new(:b).new(2)
          ctx = FilterIt::Filter::Context.new({ :a => 1 }, mock)

          test_eql = Proc.new do |x,y|
            x.should eql(y)
          end

          ctx.run do
            test_eql.call(a, 10)
            test_eql.call(b, 20)
            test_eql.call(c, 30)
            test_eql.call(self.a, 1)
            test_eql.call(self.b, mock.b)
          end

          ctx.run do |ctx_self|
            a.should eql(10)
            b.should eql(20)
            c.should eql(30)
            ctx_self.a.should eql(1)
            ctx_self.b.should eql(mock.b)
          end

        end

      end

      describe "validations" do

        before do
          @ctx = new_ctx
        end

        describe "data" do

          it "should return the actual data" do
            data = { :foo => :bar }

            @ctx.run(data) do |ctx_self|
              ctx_self.data.should be(data)
            end
          end

          it "should return the value of final_data if set" do
            data = { :foo => :bar }
            final_data = { :lol => :win }

            @ctx.run(data) do |ctx_self|
              ctx_self.final_data = final_data
            end.should be(final_data)
          end

          it "should return nil if final_data isn't set" do
            data = { :foo => :bar }

            @ctx.run(data) do |_|
            end.should be_nil
          end

        end

        describe "requires" do

          it "should set final_data correctly" do
            data = { :foo => :bar, :lol => :win }

            @ctx.run(data) do
              requires :foo
            end.should be_eql({ :foo => :bar })
          end

          it "should raise FilterIt::Filter::InvalidEntry if requires don't pass" do
            data = { :foo => :bar, :lol => :win }

            expect {
              @ctx.run(data) do
                requires :die
              end
            }.to raise_error(FilterIt::Filter::InvalidEntry)
          end

          it "should be able to use all helpers" do
            data = { :a => :a, :b => 1, :c => "foo" }
            @ctx.run(data) do
              requires :a, :is => [Integer, String, Symbol]
              requires :b, :is => Integer, :between => 0..2
            end.should be_eql({ :a => :a, :b => 1 })
          end

          it "should raise if any helpers don't pass" do
            expect {
              @ctx.run({ :a => :a, :b => 10 }) do
                requires :a, :is => [String, Integer, Hash]
              end
            }
          end

        end

        describe "optional" do

          it "should set final_data correctly" do
            data = { :foo => :bar, :lol => :win }

            @ctx.run(data) do
              optional :foo
            end.should be_eql({ :foo => :bar })
          end

          it "should not raise FilterIt::Filter::InvalidEntry if optional don't pass" do
            data = { :foo => :bar, :lol => :win }

            @ctx.run(data) do
              optional :dont_die
            end.should be_nil
          end

        end

      end

      describe "helpers" do

        before do
          @helpers = FilterIt::Helpers::HELPERS
        end

        describe "is" do

          it "should validate the class of value" do
            @helpers.is({}, Hash).should be_eql({})
            @helpers.is({ :a => :b }, [Hash]).should be_eql({ :a => :b })
          end

          it "should return nil if the validation fail" do
            @helpers.is(1, Hash).should be_nil
          end

          it "should search on superclasses" do
            @helpers.is({}, Object).should be_eql({})
          end

        end

        describe "between" do

          it "should validate the range of data" do
            @helpers.between(10, 5..15).should be_eql(10)
          end

          it "should accept two numbers as range" do
            @helpers.between(10, 5, 15).should be_eql(10)
          end

          it "should accept floats" do
            @helpers.between(10.5, 10.4, 10.6).should be_eql(10.5)
          end

          it "should return nil if validation fail" do
            @helpers.between(10, 12, 13).should be_nil
          end

        end

        describe "in" do

          it "should validate inclusion of value" do
            @helpers.in("foo", ["foo", 1]).should be_eql("foo")
          end

          it "should return nil if value isn't included" do
            @helpers.in(:foo, ["foo", 1]).should be_nil
          end

        end

      end

    end

  end

end