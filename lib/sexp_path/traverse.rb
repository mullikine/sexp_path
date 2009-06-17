module SexpPath
  module Traverse
    # Searches for the +pattern+ returning a SexpCollection containing 
    # a SexpResult for each match.
    #
    # Example:
    #   s(:a, s(:b)) / Q{ s(:b) } => [s(:b)]
    def search(pattern, data={})
      collection = SexpCollection.new
      search_each(pattern,data){|match| collection << match}
      collection
    end
    alias_method :/, :search
    
    # Searches for the +pattern+ yielding a SexpResult
    # for each match.
    #
    def search_each(pattern, data={}, &block)
      return false unless pattern.is_a? Sexp
  
      if pattern.satisfy?(self, data)
        block.call(SexpResult.new(self, data))
      end
  
      self.each do |subset|
        case subset
          when Sexp then subset.search_each(pattern, data, &block)
        end
      end
    end
    
    # Sets a named capture for the Matcher.  If a SexpResult is returned
    # any named captures will be available it.
    def capture_as(name)
      @capture_name = name
      self
    end
    alias_method :%, :capture_as

    private  
    def capture_match(matching_object, data)
      if @capture_name
        data[@capture_name] = matching_object
      end

      data
    end
  end
end