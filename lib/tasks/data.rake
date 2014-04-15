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
    puts "Building graph"

    graph = Graph.build

    puts "Done building graph"

    GC.start

    puts "Staring baconation. Hold on to your butts!"
    baconator = Bacon::Ator.new(graph)

    Actor.where(bacon_link_id: nil).where.not(name: "Kevin Bacon").find_each do |actor|
      actor.reload
      if actor.bacon_link.nil?
        start_time = Time.now
        baconator.calculate_path(actor)
        puts "Baconated #{actor.name} in #{(Time.now - start_time).to_i}s"
      else
        puts "Already baconated #{actor.name}"
      end
      STDOUT.flush
    end
  end
end
