# The Bacon::Ator is the main class behind finding the link between
# one node and Kevin Bacon. You can pass it either an Actor or Movie
# object and it will find the closest link.
#
# It runs a modified version of A* search algorithm. The biggest difference
# between Bacon::Ator and A* is that when Bacon::Ator finds a node that
# has a #bacon_link it'll switch from doing Breadth-First to Depth-First and
# follow that #bacon_link all the way to KB himself (it doesn't automatically
# return that tree. It adds all the nodes encountered to the queue for further
# investigation but will keep searching for better paths). I added this as a slight
# optimization but I'm not honestly sure it helps. It's hard to say with such
# a large data set.
#
# It can be initialized with two options:
#   logging: this indicates whether or not the processing information
#            should be output to STDOUT during the run. Defaults to true
#
#   disable_save: this indicates whether or not the Bacon::Ator should
#                 save the results by updating the bacon_link_id attribute
#                 of nodes when a result is found. Defaults to false
#
# Example:
#   actor     = Actor.where(name: "Johnny Depp").first
#   baconator = Bacon::Ator.new
#   baconator.calculate_path(actor)
#   baconator.print
#    # => Johnny Depp
#    # => Once Upon a Time in Mexico
#    # => Micky Rourke
#    # => Diner
#    # => Kevin Bacon
#
# Because there are many paths from one node to Kevin Bacon results aren't
# guaranteed to be the same between runs.
#
# A single Bacon::Ator instance can safely run a search across any number
# of elements.
#
module Bacon
  class Ator
    attr_reader :options, :queue, :marked, :final, :target, :final_path, :start, :graph

    def initialize(graph, options = {})
      @graph   = graph

      @options = {
        logging: false,
        disable_save: false
      }.merge options
    end

    def reset_baconator(actor)
      point = graph.find_actor(actor)
      node  = Bacon::Node.create(point, 0)

      @start      = point
      @queue      = Bacon::Array[node]
      @marked     = []
      @final      = nil
      @steps      = 0
      @processed  = 0
      @started    = Time.now
      @final_path = []
      @target     = bacon
    end

    # This is the main entry point to do a search on a node.
    #
    # It takes a single argument:
    #   actor: Actor is the node that you want to find a path
    #          to KB from.
    #
    # It returns an array (sorted with your input first) that
    # is the path from your node to KB himself!
    #
    def calculate_path(actor)
      reset_baconator(actor)
      node_search do |current_node|
        process_single_node(current_node)
      end
    end

    def print
      puts ""
      final_path.each do |element|
        puts element.name
      end
    end

    private

    def process_single_node(node)
      continue_unless_match(node) do
        marked << node
        process_node_edges(node)
      end
    end

    def process_node_edges(node)
      node.edges.each do |edge|
        new_node      = Bacon::Node.create(edge, node.depth + 1, node)
        process_new_node(new_node)
      end
    end

    # This is the heart of the algorithm, the rest is just dressing.
    # This method takes a newly created node and checks for a few conditions:
    #   1. if the node is in the current queue. If it is, check to see if our
    #      new node is better than the one in the queue. If it is, delete the
    #      one in the queue.
    #   2. if the node is in the marked list. If it is, and it's better than
    #      the one on the marked list, remove it from the marked list and try
    #      to find a path via this node
    #   3. otherwise it just adds it to the queue
    #
    def process_new_node(node)
      continue_unless_match(node) do
        if (node_in_queue = queue.find { |n| n.name == node.name }).present?
          if node.depth < node_in_queue.depth
            queue.delete(node_in_queue)
            queue << node
          end
        elsif (node_in_queue = marked.find { |n| n.name == node.name }).present?
          if node.depth < node_in_queue.depth
            marked.delete(node_in_queue)
            queue << node
          end
        else
          @steps += 1
          queue  << node
        end
      end
    end

    # This is our early exit method. Before I added this the algorithm would
    # frequently encounter Kevin Bacon and add him to the queue to be processed
    # later. I think this is fine for normal A* because the queue doesn't
    # usually contain 15k+ nodes. This method is to detect a KB occurrence along
    # an edge and return it immediately.
    #
    def continue_unless_match(node)
      if match_target?(node)
        mark_final(node)
      else
        yield
      end
    end

    def match_target?(node)
      node.name == target.name
    end

    def mark_final(node)
      @final = node
    end

    # This method handles the search itself, iterating from node to node always
    # picking one that is more likely to be the "closest". When the search is over
    # it does some cleanup, saves results and returns the final link
    #
    def node_search
      while (current_node = queue.shift).present? && final.nil?
        @processed += 1
        yield(current_node)
        log "\rProcessing #{start.name}.... %d / %d @ %ds - depth: %d", @processed, @steps, (Time.now - @started), current_node.depth
      end

      format_results
      save_results if final.present?
      self.final_path
    end

    # This method just iterates over the final_path array and
    # sets bacon_links if they haven't been set already
    #
    def save_results
      unless self.options[:disable_save] == true

        bacon_distance = self.final_path.length
        self.final_path.inject(nil) do |previous, link|
          link.bacon_distance = bacon_distance unless link.bacon_distance.present?
          bacon_distance -= 1
          unless previous.nil? || previous.element.bacon_link.present?
            previous.element.update_attribute(:bacon_link_id, link.element.id)
          end
          link
        end
      end

      self.final_path
    end

    def format_results
      node = final
      while node.present?
        final_path << node.element
        node = node.parent
      end

      final_path << self.start if final_path.last != self.start

      self.final_path.reverse!
    end

    def bacon
      @bacon ||= Actor.where(name: "Kevin Bacon").first
    end

    

    def log(*args)
      if options[:logging]
        printf(*args)
        STDOUT.flush
      end
    end
  end
end

