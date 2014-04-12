require 'spec_helper'

describe FilmParser do
  it "" do
    json   = JSON::parse(Rails.root.join("db", "films", "11.json").read)
    parser = FilmParser.new
    parser.parse_json(json)

    Movie.count.should eq 1
    Actor.count.should eq 105

    movie = Movie.first
    movie.actors.cound.should eq 105
  end
end
