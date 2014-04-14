# The FilmParser can parse a single movie JSON file or scan an
# entire directory for JSON files and create Movie and Actor
# objects from them, as well as their relationships. Running
# the parse is idempotent.
#
class FilmParser
  KEY = {
    :film  => "film",
    :cast  => "cast",
    :name  => "name",
    :image => "image"
  }

  DATA_PATH = Rails.root.join("db", "films")

  def parse_directory(pathname = DATA_PATH)
    pathname.children.each { |child| parse_file(child) } if pathname.directory?
  end

  # Shortcut to parse_json, accepts a pathname
  def parse_file(pathname)
    parse_json(JSON::parse(pathname.read), pathname.basename.to_s) if pathname.exist?
  end

  def parse_json(json, filename)
    movie  = parse_film(json, filename)
    actors = parse_cast(json)

    movie.actors << actors
  end

  # Returns a *Movie* object
  #
  def parse_film(json, filename)
    film = json[KEY[:film]]

    selector = Movie.where(:name => film[KEY[:name]]).where(:filename => filename)
    movie    = selector.first || selector.create

    movie.update_attributes(:image_url => film[KEY[:image]])
    movie
  end

  # Returns an array of *Actor* objects
  #
  def parse_cast(json)
    json[KEY[:cast]].map { |cast| parse_actor(cast) }
  end

  def parse_actor(cast)
    selector = Actor.where(:name => cast[KEY[:name]])
    actor = selector.first || selector.create

    actor.update_attributes(:image_url => cast[KEY[:image]])
    actor
  end
end
