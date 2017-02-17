
require "search_cop_grammar"
require "treetop"

Treetop.load File.expand_path("../../search_cop_grammar.treetop", __FILE__)

module SearchCop
  class GrammarParser
    attr_reader :query_info

    def initialize(query_info)
      @query_info = query_info
    end

    def parse(string)
      if @query_info.scope.reflection.sanitize['like']
        escape_character = "\\"
        pattern = Regexp.union(escape_character, "%", "_")
        string = string.gsub(pattern){|x| [escape_character, x].join}
      end
      node = SearchCopGrammarParser.new.parse(string) || raise(ParseError)
      node.query_info = query_info
      node.evaluate
    end
  end
end
