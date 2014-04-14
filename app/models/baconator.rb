# The Baconator is the main class behind finding the link between
# one node and Kevin Bacon. You can pass it either an Actor or Movie
# object and it will find the closest link.
#
# It runs a modified version of A* search algorithm. The biggest difference
# between Bacon::Ator and A* is that when Bacon::Ator finds a node that
# has a #bacon_link it'll switch from doing Breadth-First to Depth-First and
# follow that #bacon_link all the way to KB himself (it doesn't automatically
# return that tree. It adds all the nodes encountered to the queue for further
# investigation but will keep search for better paths). I added this as a slight
# optimization but I'm not honestly sure it helps. It's hard to say with such
# a large data set.
#
# It can be initialized with two options:
#   logging: this indicates whether or not the processing information
#            should be output to STDOUT during the run. Defaults to true
#
#   disable_save: this indicates whether or not the Baconator should
#                 save the results by updating the bacon_link_id attribute
#                 of nodes when a result is found. Defaults to false
#
# Example:
#   actor     = Actor.where(name: "Johnny Depp").first
#   baconator = Baconator.new
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
class Baconator
  attr_reader :options, :queue, :marked, :final, :target, :final_link, :start

  def initialize(options = {})
    @options = {
      logging: false,
      disable_save: false
    }.merge options
  end

  def reset_baconator(actor)
    node = Bacon::Node.create(actor, 0)

    @start      = actor
    @queue      = Bacon::Array[node]
    @marked     = []
    @final      = nil
    @steps      = 0
    @processed  = 0
    @started    = Time.now
    @final_link = []
    @target     = target
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
      check_existing_bacon_link(current_node)
    end
  end

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

  def node_search
    while (current_node = queue.shift).present? && final.nil?
      @processed += 1
      yield(current_node)
      log "\rProcessing #{start.name}.... %d / %d @ %ds - depth: %d", @processed, @steps, (Time.now - @started), current_node.depth
    end

    format_results
    save_results if final.present?
    self.final_link
  end

  def check_existing_bacon_link(node)
    element = node.element

    while element.bacon_link.present?
      new_node = Bacon::Node.create(element.bacon_link, node.depth + 1, node)
      break if new_node.bacon?
      process_new_node(new_node)
      element  = element.bacon_link
      node     = new_node
    end
  end

  def save_results
    unless self.options[:disable_save] == true
      self.final_link.inject(nil) do |previous, link|
        unless previous.nil? || previous.bacon_link.present?
          previous.update_attribute(:bacon_link_id, link.id)
        end
        link
      end
    end

    self.final_link
  end

  def format_results
    node = final
    while node.present?
      final_link << node.element
      node = node.parent
    end

    final_link << self.start if final_link.last != self.start

    self.final_link.reverse!
  end

  def bacon
    @bacon ||= Actor.where(name: "Kevin Bacon").first
  end

  def print
    puts ""
    final_link.each do |element|
      puts element.name
    end
  end

  private
  def log(*args)
    if options[:logging]
      printf(*args)
      STDOUT.flush
    end
  end
end

