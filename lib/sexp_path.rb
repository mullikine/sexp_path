require 'sexp_processor'

module SexpPath
  
  # SexpPath Matchers are used to build SexpPath queries.
  #
  # See also: SexpQueryBuilder
  module Matcher  
  end
end

%w[
  traverse 
  sexp_query_builder
  ruby_query_builder
  sexp_result
  sexp_collection
  
  matcher/base
  matcher/any
  matcher/all
  matcher/not
  matcher/child
  matcher/block
  matcher/atom
  matcher/pattern
  matcher/type
  matcher/wild
  matcher/remaining
  matcher/include
  matcher/sibling
  
].each do |path|
  require_relative "./sexp_path/#{path}"
end

# Pattern building helper, see SexpQueryBuilder
def Q?(&block)
  SexpPath::SexpQueryBuilder.do(&block)
end

# Ruby specific builder
def R?(&block)
  SexpPath::RubyQueryBuilder.do(&block)
end

# SexpPath extends Sexp with Traverse.
# This adds support for searching S-Expressions
class Sexp
  include SexpPath::Traverse
  
  # Extends Sexp to allow any Sexp to be used as a SexpPath matcher
  def satisfy?(o, data={})
    return false unless o.is_a? Sexp
    return false unless length == o.length || (last.is_a?(Sexp) && last.greedy?)
    
    each_with_index do |child,i|
      if child.is_a?(Sexp)
        candidate = child.greedy? ? o[i..-1] : o[i]
        return false unless child.satisfy?( candidate, data )
      else
        return false unless child == o[i]
      end
    end

    capture_match(o, data)
  end
end