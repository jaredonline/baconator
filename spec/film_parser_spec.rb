require 'spec_helper'

# TODO clean up these integration tests
describe FilmParser do
  let(:parser) { FilmParser.new }
  let(:file)   { "13" }
  let(:dir)    { Rails.root.join("spec", "support", "data", "films") }
  let(:path)   { dir.join( "#{file}.json") }
  let(:json)   { JSON::parse(path.read) }

  it "creates all the actors and movies" do
    parser.parse_json(json, path.basename.to_s)

    Movie.count.should eq 1
    Actor.count.should eq 9

    movie = Movie.first
    movie.actors.count.should eq 9

    actor = Actor.first
    actor.movies.count.should eq 1
    actor.movies.first.should eq movie
  end

  describe "directory based parsing" do
    it "parses a directory" do
      parser.parse_directory(dir)

      Movie.count.should eq 4
    end

    context "path isn't a directory" do
      it "silently returns" do
        parser.parse_directory(path)

        Movie.count.should eq 0
      end
    end
  end

  describe "filename based parsing" do
    it "parses via a filename" do
      parser.parse_file(path)

      Movie.count.should eq 1
    end

    context "file doesn't exist" do
      let(:file) { "0" }

      it "silently returns" do
        path.should_not_receive(:read)
        parser.parse_file(path)
      end
    end
  end

  # If the same film appears in the data set twice
  # we'll be safe from creating an extra Movie object
  # or extra Actor objects, but the association from
  # Movie to Actor will be duplicated. This test covers
  # that
  it "won't duplicate actor/movie relationships" do
    parser.parse_json(json, path.basename.to_s)

    movie = Movie.first
    actor = Actor.first

    movie.actors.count.should eq 9
    actor.movies.count.should eq 1

    parser.parse_json(json, path.basename.to_s)

    movie.actors.count.should eq 9
    actor.movies.count.should eq 1
  end

  it "won't confuse movies with the same name but different files" do
    json = {
      "film" => {
        "name"  => "Last Holiday",
        "image" => ""
      },
      "cast"  => []
    }.to_json

    parser.parse_film(json, "1.json")
    parser.parse_film(json, "2.json")

    Movie.count.should eq 2
  end

  describe "actor create" do
    it "should set the image tag" do
      cast = json["cast"].first
      actor = parser.parse_actor(cast)
      actor.image_url.should eq "http://image.tmdb.org/t/p/w185/xxPMucou2wRDxLrud8i2D4dsywh.jpg"
    end
  end

  describe "movie create" do
    it "should set the image tag" do
      movie = parser.parse_film(json, path.basename.to_s)
      movie.image_url.should eq "http://image.tmdb.org/t/p/w185/z4ROnCrL77ZMzT0MsNXY5j25wS2.jpg"
    end
  end
end
