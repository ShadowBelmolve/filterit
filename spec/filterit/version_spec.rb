describe FilterIt::VERSION do

  it "have 2 dots" do
    FilterIt::VERSION.split(".").count.should eql(3)
  end

end