module GraphParser
  class Entity
    attr_accessor :name
    attr_accessor :id
    attr_accessor :node
    
    def initialize(id, name)
      @name = name
      @id = id
    end
  end
end