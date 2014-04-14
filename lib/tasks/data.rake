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

    puts ""

    GC.start

    puts "Staring baconation. Hold on to your butts!"
    baconator = Bacon::Ator.new(graph)

    # Start off by setting all movies KB is in to link
    # back to him directly
    kevin = Actor.where(name: "Kevin Bacon").first
    kevin.movies do |movie|
      movie.update_attribute(:bacon_link_id, kevin.id)
    end

    Actor.where(bacon_link_id: nil).where.not(name: "Kevin Bacon").find_each do |actor|
      actor.reload
      if actor.bacon_link.nil?
        start_time = Time.now
        baconator.calculate_path(actor)
        puts "Baconated #{actor.name} in #{(Time.now - start_time).to_i}s"
        GC.start
      else
        puts "Already baconated #{actor.name}"
      end
    end
  end
end
