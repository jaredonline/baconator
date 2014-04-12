class FilmParser
  def parse_json(json)
    selector = Movie.where(:name => json["film"]["name"])
    movie    = selector.first || selector.create

    json["cast"].each do |cast|
      selector = Actor.where(:name => cast["name"])
      actor    = selector.first || selector.create
    end
  end
end
