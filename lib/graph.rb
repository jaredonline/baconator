class Graph
  def initialize
    @actors = Array.new
    @movies = Array.new
  end

  def add_actor(actor)
    @actors[actor.id] ||= ActorNode.new(actor)
  end
  
  def add_movie(movie)
    @movies[movie.id] ||= MovieNode.new(movie)
  end

  def actors
    @actors.compact
  end

  def find_actor(actor)
    @actors[actor.id]
  end

  def movies
    @movies.compact
  end

  def find_movie(movie)
    @movies[movie.id]
  end

  def connect(actor, movie)
    actor_node = find_actor(actor)
    movie_node = find_movie(movie)

    if actor_node.present? && movie_node.present?
      actor_node.add_connection(movie_node)
      movie_node.add_connection(actor_node)
    end
  end
end

class MovieNode
  attr_reader :movie, :connections

  def initialize(movie)
    @movie       = movie
    @connections = Set.new
  end

  def element
    movie
  end

  def add_connection(actor_node)
    @connections << actor_node
  end
end

class ActorNode
  attr_reader :actor, :connections

  def initialize(actor)
    @actor       = actor
    @connections = Set.new
  end

  def element
    actor
  end

  def add_connection(movie_node)
    @connections << movie_node
  end
end
