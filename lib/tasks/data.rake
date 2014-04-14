desc "This runs bacon:import_films and bacon:precalculate_paths"
task :bacon => ["bacon:import_films", "bacon:precalculate_paths"] do
end

namespace :bacon do
  desc "This will drop all Actors and Movies in the DB and re-import them"
  task :import_films => :environment do
    puts "Trashing actors and movies"
    Actor.delete_all
    Movie.delete_all

    puts "Importing actors and movies"
    film_parser = FilmParser.new
    film_parser.parse_directory
  end

  desc "This will run bacon link path calculation for all actors"
  task :precalculate_paths => :environment do
    puts "Staring baconation. Hold on to your butts!"
    baconator = Baconator.new logging: true

    # Start off by setting all movies KB is in to link
    # back to him directly
    kevin = Actor.where(name: "Kevin Bacon").first
    kevin.movies do |movie|
      movie.update_attribute(:bacon_link_id, kevin.id)
    end

    Actor.where(bacon_link_id: nil).where.not(name: "Kevin Bacon").all.each do |actor|
      baconator.calculate_path(actor)
      puts "Baconated #{actor.name}!"
    end
  end
end
