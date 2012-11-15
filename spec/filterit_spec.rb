describe FilterIt do

  before(:each) do
    FilterIt.instance_variable_set :@filters, {}
  end

  describe "register_filter" do

    it "not register filters without a name" do
      expect { FilterIt.register_filter(nil){} }.to raise_error(ArgumentError)
    end

    it "not register filters without a block" do
      expect { FilterIt.register_filter("filter") }.to raise_error(ArgumentError)
    end

    it "register a filter and return an instance of FilterIt::Filter" do
      FilterIt.register_filter("filter") {}.class.should eql(FilterIt::Filter)
    end

    it "accept any non-nil value as name" do
      [false, true, 1, "a", :b, FilterIt].each do |name|
        FilterIt.register_filter(name){}.class.should eql(FilterIt::Filter)
      end
    end

    it "not accept duplicated names" do
      FilterIt.register_filter("filter"){}
      expect { FilterIt.register_filter("filter"){} }.to raise_error(ArgumentError)
    end

  end

  it "get_filter should return the filter or nil" do
    filter = FilterIt.register_filter('foo'){}
    FilterIt.get_filter('foo').should eql(filter)
    FilterIt.get_filter('lol').should be_nil
  end

end