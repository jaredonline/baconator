class SortedArray < Array

  def self.[] *array
    SortedArray.new(array)
  end

  def initialize array=nil
    super( array.sort_by(&:depth) ) if array
  end

  def <<(value)
    insert index_of_last_LE(value.depth), value
  end

  alias push <<

  def index_of_last_LE(value)
    l,r = 0, length-1
    while l <= r
      m = (r+l) / 2
      if value < self[m].depth
        r = m - 1
      else
        l = m + 1
      end
    end
    l
  end
end

class Baconator
  attr_reader :options, :queue, :marked, :final, :target, :final_link, :start

  def initialize(options = {})
    @options = {
      logging: false,
      disable_save: false
    }.merge options
  end

  def reset_baconator(actor)
    node = BaconNode.create(actor, 0)

    @start      = actor
    @queue      = SortedArray[node]
    @marked     = []
    @final      = nil
    @steps      = 0
    @processed  = 0
    @started    = Time.now
    @final_link = []

    set_target(bacon)
  end

  def set_target(target)
    @target = target
  end

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
      new_node      = BaconNode.create(edge, node.depth + 1, node)
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
      new_node = BaconNode.create(element.bacon_link, node.depth + 1, node)
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

class BaconNode
  def self.create(element, depth, parent = nil)
    klass = if element.is_a?(Actor)
              ActorBaconNode
            elsif element.is_a?(Movie)
              MovieBaconNode
            else
              raise "element must be of class Actor or Movie, was #{element.class}"
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
end

class ActorBaconNode < BaconNode
  def bacon?
    name == "Kevin Bacon"
  end

  def edges
    actor.movies
  end

  def actor
    element
  end
end

class MovieBaconNode < BaconNode
  def ==(object)
    return super unless object.is_a?(MovieBaconNode)
    movie.name == object.movie.name
  end

  def edges
    movie.actors
  end

  def movie
    element
  end
end
