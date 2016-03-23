
class RecursiveCaseIndifferentOstruct
  DEFAULT_CASE=:snake
  attr_accessor :default_case
  
  def initialize(hash={}, casing=nil)
    @default_case = casing || DEFAULT_CASE
    @hash         = hash
  end
  
  def to_h
    @hash
  end
  
  def [](key)
    handle_get(key)
  end

  def []=(key, value)
    handle_assignment(key, value, true)
  end

  def merge(other_hash)
    out = self.dup
    other_hash.each do |k, v|
      out.send("#{k}=", v)
    end
    out
  end
  
  def merge!(other_hash)
    other_hash.each do |k, v|
      send("#{k}=", v)
    end
  end
  
  def method_missing(method_sym, *args, &block)
    method_name   = method_sym.to_s
    is_assignment = method_name.slice(-1) == '='
    is_get        = !is_assignment && args.length == 0 && !@hash.respond_to?(method_name)
    
    # remove = if an assignment
    if is_assignment
      method_name = method_name.slice(0, method_name.length - 1)
    end
    
    if is_assignment
      return handle_assignment(method_name, args.first)
    elsif is_get
      return handle_get(method_name)
    else
      @hash.send(method_name, *args, &block)
    end
    
    # if they called a function and passed some args, then
    # raise no method error
    #super
  end
  
  def case_being_used
    # TODO: If all nil then scan for keys in nested hashes
    cases_found = @hash.keys.map do |key|
      if !key.to_s.match(/^[a-z]+\-[a-z]/).nil? # kabab
        :kabab
      elsif key.to_s.include?('_')# snake
        :snake
      elsif !key.to_s.match(/^[a-z]+[A-Z]/).nil? # lower camel
        :lower_camel
      elsif !key.to_s.match(/^[A-Z][a-z]+[A-Z]/).nil? # upper camel
        :upper_camel
      elsif !key.to_s.match(/^[A-Z][a-z]+\-[A-Z]/).nil? # Train-Case
        :train
      else
        # Could just be one word in that case who knows what case it is
        nil
      end
    end
    
    if cases_found.compact.uniq.size == 1
      cases_found.compact.first
    else
      return @default_case
    end
    
  end

  def find_matching_keys(to_find)
    @hash.keys.select do |key|
      self.class.clean_key(to_find) == self.class.clean_key(key)
    end
  end

  # string for comparison
  def self.clean_key(key)
    key.to_s.downcase.gsub(/[\W_]/, '')
  end

  private
  def handle_assignment(method_name, value, allow_override=false)
    # assign all matching keys
    keys = find_matching_keys(method_name)

    # assigning a new value
    if keys.empty?
      # allow custom case via []=
      if method_name.is_a?(String) && allow_override
        @hash[method_name] = value
      else
        @hash[ensure_default_case(method_name)] = value
      end
      
    end
    
    keys.each do |key|
      @hash[key] = value
    end
    
    value
  end
  
  def handle_get(method_name)
    keys = find_matching_keys(method_name)
    
    value = @hash[keys.first]

    if value.is_a?(Array)
      # Make any hashes in the array an ostruct
      value.map do |item|
        item.is_a?(Hash) ? RecursiveCaseIndifferentOstruct.new(item, @default_case) : item
      end
    elsif value.is_a?(Hash)
      RecursiveCaseIndifferentOstruct.new(value, @default_case)
    else
      value
    end
  end
  
  
  def ensure_default_case(key)
    # Pull out the words/numbers from the key name
    # find:     lower          camel             UPCASE       numbers
    re = /( (?:[a-z]+) | (?:[A-Z][a-z]+) | (?:[A-Z]+) |   [0-9]+  )/x
    words = key.to_s.scan(re).map do |word|
      word = word.first
      if word.scan(/[A-Z]/).size < 2
        word.downcase
      else
        word # it's an acronym in whichcase lets leave it.
      end
    end
    
    if @default_case == :snake
      words.join('_')
      
    elsif @default_case == :kabab
      words.join('-')
      
    elsif @default_case == :lower_camel
      words.map.with_index do |w, i|
        if i > 0
          w[0] = w[0].upcase
          w
        else
          w
        end
      end.join      
      
    elsif @default_case == :upper_camel
      words.map do |w|
        w[0] = w[0].upcase
      end.join
      
    elsif @default_case == :train
      words.map do |w|
        w[0] = w[0].upcase
      end.join('-')
    end
    
  end
  
end
