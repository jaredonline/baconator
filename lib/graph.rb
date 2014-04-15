class Graph
  def self.build
    total_movies = Movie.count

    graph = Graph.new
    Movie.all.find_each.with_index do |movie, index|
      printf "\rAdding movie #{index} / #{total_movies}"
      movie_point = graph.add_movie(movie)

      movie.actors.each do |actor|
        actor_point = graph.add_actor(actor)

        graph.connect(actor_point, movie_point)
      end
    end
    graph
  end

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

  def initialize(element)
    @element        = element
    @connections    = Set.new
  end

  def name
    @name ||= element.name
  end

  def add_connection(point)
    @connections << point
  end

  def to_s
    "<#{self.class.to_s} movie=#{element.name.inspect} connections=#{connections.count} >"
  end

  def inspect
    to_s
  end
end

class MoviePoint < Point
  def movie
    element
  end
end

class ActorPoint < Point
  def actor
    element
  end
end
