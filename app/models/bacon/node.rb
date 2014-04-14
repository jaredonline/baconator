module Bacon
  # The Bacon::Node class represents a single Actor or Movie
  # currently being explored by the Bacon::Ator class.
  # The Node parent class utilizes a factory via ::create
  # to create the correct node time based on the element passed it.
  #
  # Each Node is initialized with the element, the current search depth
  # and an optional parent. The parent is linked so once we find the
  # elusive Kevin Bacon we can trace the parents back up, linked list style.
  #
  # We use the depth as proxy heuristic or g-cost in the A* algorithm. It's
  # not super great but it's the best I could come up with.
  #
  # It comes with a few helper methods to make it a bit easier to
  # traverse the graph (via #edges, #== and #bacon?)
  #
  class Node
    def self.create(element, depth, parent = nil)
      klass = if element.is_a?(ActorPoint)
                ActorNode
              elsif element.is_a?(MoviePoint)
                MovieNode
              else
                raise "element must be of class ActorPoint or MoviePoint, was #{element.class}"
              end

      klass.new(element, depth, parent)
    end

    attr_reader :parent, :element, :depth

    def to_s
      "#{name} -- #{depth} -- #{parent.nil? ? "[root]" : parent.name}"
    end

    def initialize(element, depth, parent)
      @element = element
      @parent  = parent
      @depth   = depth
    end

    # Because this doesn't change after a node's initialization
    # we store the length in a memoized variable
    #
    def length
      @length ||= begin
        length = 0
        node   = self.dup
        while node.present?
          length += 1
          node = node.parent
        end

        length
      end
    end

    def ==(object)
      return super unless object.is_a?(self.class)
      name == object.name
    end

    def bacon?
      false
    end

    def name
      element.name
    end

    def edges
      element.connections
    end
  end

  class ActorNode < Node
    def bacon?
      name == "Kevin Bacon"
    end

    def actor
      element
    end
  end

  class MovieNode < Node
    def movie
      element
    end
  end
end
