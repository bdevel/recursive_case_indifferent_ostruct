require "minitest/autorun"
require_relative "test_helpers"


describe RecursiveCaseIndifferentOstruct do
  
  before do
  end


  describe "#case_being_used" do
    it "should find snake" do
      obj, hash = TestHelpers.build_with_keys([:my_key, :other], :default_case)
      assert_equal :snake, obj.case_being_used
    end
    
    it "should find lower camel" do
      obj, hash = TestHelpers.build_with_keys([:myKey, :other], :default_case)
      assert_equal :lower_camel, obj.case_being_used
    end
    
    it "should find upper camel" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "Other"], :default_case)
      assert_equal :upper_camel, obj.case_being_used
    end

    it "should use default if mixed" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "other_key"], :default_case)
      assert_equal :default_case, obj.case_being_used
    end
    
  end

  describe "#find_matching_keys" do
    it "finds all cases" do
      key_list = ["MyKey", :my_key, "my-key", "myKey", "My-Key"]
      obj, hash = TestHelpers.build_with_keys(key_list)
      assert_equal key_list, obj.find_matching_keys('myKey')
    end    
  end

  describe "#[]=" do
    it "handles assignment of existing" do
      obj, hash    = TestHelpers.build_with_keys(["MyKey"])
      obj[:my_key] = 123
      
      assert_equal 123, obj.my_key
      assert_equal 123, obj["MyKey"]
      assert_equal 123, hash["MyKey"]
    end

    it "handles assignment of new attr" do
      obj = RecursiveCaseIndifferentOstruct.new({}, :lower_camel)
      obj[:my_key]     = 123
      assert_equal( {"myKey" => 123}, obj.to_h)
    end

    it "handles assignment of custom case" do
      obj = RecursiveCaseIndifferentOstruct.new({}, :snake)
      obj["MY:KEY"]     = 123
      assert_equal({"MY:KEY" => 123}, obj.to_h)
      assert_equal 123, obj.my_key
    end
    
  end

  describe "#[]" do
    it "gets value" do
      obj, hash    = TestHelpers.build_with_keys(["MyKey"])
      assert_equal hash["MyKey"], obj[:my_key]
      assert_equal hash["MyKey"], obj["my_key"]
    end

    it "default value is nil" do
      obj = RecursiveCaseIndifferentOstruct.new({})
      assert_equal nil, obj[:my_key]
    end
  end
  
  describe "#method_missing" do
    it "handles assignment of existing" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "other-key"])
      obj.my_key    = 123
      obj.other_key = 456

      assert_equal 123, obj.to_h["MyKey"]
      assert_equal 123, hash["MyKey"]
      
      assert_equal 456, obj.to_h["other-key"]
      assert_equal 456, hash["other-key"]
    end

    it "will change attr to default case" do
      obj = RecursiveCaseIndifferentOstruct.new({}, :lower_camel)
      obj.foo_bar = 123
      assert_equal({"fooBar" => 123}, obj.to_h)
    end
    
    it "can get existing values" do
      obj = RecursiveCaseIndifferentOstruct.new({"myKey" => 123})
      assert_equal 123, obj.my_key
    end
    
    it "nil is default get" do
      obj = RecursiveCaseIndifferentOstruct.new({"myKey" => 123})
      assert_equal nil, obj.other_key
    end

    it "raises exception if calling missing method" do
      obj = RecursiveCaseIndifferentOstruct.new({"myKey" => 123})
      begin
        obj.foo_bar('arg1')
        assert false, "did not raise NoMethodError"
      rescue Exception => e
        assert e.is_a?(NoMethodError), "did not raise NoMethodError"
      end
    end
    
  end



  
  describe "rescursiveness" do
    it "will wrap nested hashes" do
      obj = RecursiveCaseIndifferentOstruct.new({
                                                  nestedHash: {
                                                    nestedValue: 123
                                                  }
                                                })
      
      assert_equal 123, obj.nested_hash.nested_value
    end

    it "will wrap hashes in arrays" do
      obj = RecursiveCaseIndifferentOstruct.new({
                                                  myArray: [
                                                    {nestedValue: 123}
                                                  ]
                                                })
      
      assert_equal 123, obj.my_array[0].nested_value
    end

    it "returns proper #to_h" do
      obj = RecursiveCaseIndifferentOstruct.new({
                                                  myArray: [
                                                    {nestedValue: 123}
                                                  ],
                                                  nestedHash: {
                                                    nestedValue: 123
                                                  }
                                                }, :lower_camel)
      
      obj.my_array[0].nested_value = 456
      obj.my_array[0].other_value   = 999

      expected = {
        :myArray=>[{:nestedValue=>456, "otherValue"=>999}],
        :nestedHash=>{:nestedValue=>123}
      }
      assert_equal expected, obj.to_h
    end


    it "will keep the default case" do
      obj = RecursiveCaseIndifferentOstruct.new({
                                                  myArray: [
                                                    {nestedValue: 123}
                                                  ],
                                                  nestedHash: {
                                                    nestedValue: 123
                                                  }
                                                }, :lower_camel)
      
      assert_equal :lower_camel, obj.my_array[0].default_case
      assert_equal :lower_camel, obj.nested_hash.default_case
    end
    
  end


  
  describe "acting like a hash" do
    it "has #has_key?" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "other-key"], :lower_camel)
      obj.new_key = 123
      
      assert obj.has_key?("MyKey"), "no my #{obj.keys.inspect}"
      assert obj.has_key?("other-key"), "no other"
      assert obj.has_key?("newKey"), "did not add new key (#{obj.keys.inspect})"
    end

    it "has #each" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "other-key"], :lower_camel)
      obj.each do |k, v|
        assert_equal hash[k], v
      end
    end

    it "has #delete" do
      obj, hash = TestHelpers.build_with_keys(["MyKey", "other-key"], :lower_camel)
      obj.delete "MyKey"
      obj.delete :other_key
      assert_equal false, obj.has_key?("MyKey")
      assert_equal true, obj.has_key?("other-key") # wont delete this
    end
    
    
  end
  
end

