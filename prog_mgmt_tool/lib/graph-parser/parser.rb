require 'nokogiri'

module GraphParser
  class Parser
    attr_reader :filename
    attr_reader :graph

    def initialize(filename)
      @filename = filename

      if File.exist?(filename)
        file = File.open(filename)
        @graph = Nokogiri::XML(file)
        if @graph.nil?
          p "Error while opening gxml file."
        end
      else
        p "File not found"
      end

    end

    def parse
      
      self.graph.root.children.each do |c|
        p c.keys
      end
    end
  
  private

  end
end