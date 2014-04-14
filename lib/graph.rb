class Graph
  def initialize
    @actors = Array.new
    @movies = Array.new
  end

  def add_actor(actor)
    @actors[actor.id] ||= ActorPoint.new(actor)
  end
  
  def add_movie(movie)
    @movies[movie.id] ||= MoviePoint.new(movie)
  end

  def actors
    @actors.compact
  end

  def find_actor(actor)
    selector = actor.is_a?(ActorPoint) ? actor.element : actor
    @actors[selector.id]
  end

  def movies
    @movies.compact
  end

  def find_movie(movie)
    selector = movie.is_a?(MoviePoint) ? movie.element : movie
    @movies[selector.id]
  end

  def connect(actor, movie)
    actor_point = find_actor(actor)
    movie_point = find_movie(movie)

    if actor_point.present? && movie_point.present?
      actor_point.add_connection(movie_point)
      movie_point.add_connection(actor_point)
    end
  end
end

class Point
  attr_reader   :element, :connections
  attr_accessor :bacon_distance

  def initialize(element)
    @element        = element
    @connections    = Set.new
    @bacon_distance = nil
  end

  def name
    element.name
  end

  def to_s
    "<MoviePoint movie=#{element.name.inspect} connections=#{connections.count} >"
  end

  def inspect
    to_s
  end
end

class MoviePoint < Point
  def movie
    element
  end

  def add_connection(actor_point)
    @connections << actor_point
  end
end

class ActorPoint < Point
  def actor
    element
  end

  def add_connection(movie_point)
    @connections << movie_point
  end
end
