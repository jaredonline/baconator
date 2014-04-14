require 'spec_helper'

describe Graph do
  let(:graph) { Graph.new }
  let(:actor) { Actor.create(name: "Kevin Bacon") }
  let(:movie) { Movie.create(name: "Diner") }

  describe 'adding points' do
    it 'can add actors' do
      graph.add_actor(actor)
      graph.actors.length.should eq 1
    end

    it 'can add movies' do
      graph.add_movie(movie)
      graph.movies.length.should eq 1
    end

    context 'returns points' do
      it 'returns a movie point' do
        graph.add_movie(movie).should be_a MoviePoint
      end

      it 'returns an actor point' do
        graph.add_actor(actor).should be_a ActorPoint
      end
    end

    context 'point already exists' do
      before do
        graph.add_actor(actor)
        graph.add_movie(movie)
      end

      it 'doesnt add more than one' do
        graph.add_actor(actor)
        graph.actors.length.should eq 1
      end
    end
  end

  describe 'adding connections' do
    it 'adds connections' do
      an = graph.add_actor(actor)
      mn = graph.add_movie(movie)

      graph.connect(actor, movie)

      an.connections.should be_include mn
      mn.connections.should be_include an
    end
  end

  describe 'finding points' do
    it 'can find actors' do
      graph.add_actor(actor)
      graph.find_actor(actor).element.should == actor
    end

    it 'can find movies' do
      graph.add_movie(movie)
      graph.find_movie(movie).element.should == movie
    end

    context 'finding a point with a point' do
      it 'can find actor points' do
        an = graph.add_actor(actor)
        graph.find_actor(an).should be_a ActorPoint
      end

      it 'can find actor points' do
        mv = graph.add_movie(movie)
        graph.find_movie(mv).should be_a MoviePoint
      end
    end

    context 'points not in graph' do
      it 'returns nil' do
        graph.find_movie(movie).should be_nil
      end

      it 'returns a point' do
        graph.add_movie(movie)
        graph.find_movie(movie).should be_a MoviePoint
      end
    end
  end

end
