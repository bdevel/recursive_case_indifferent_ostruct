require 'recursive_case_indifferent_ostruct'

module TestHelpers

  def self.build_with_keys(keys, default_case=nil)
    hash = keys.inject({}) {|sum, i| sum[i] = rand(); sum}    
    return [
      RecursiveCaseIndifferentOstruct.new(hash, default_case),
      hash
    ]
  end
  
end
