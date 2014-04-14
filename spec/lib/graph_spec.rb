require 'spec_helper'

describe Graph do
  let(:graph) { Graph.new }
  let(:actor) { Actor.create(name: "Kevin Bacon") }
  let(:movie) { Movie.create(name: "Diner") }

  describe 'adding nodes' do
    it 'can add actors' do
      graph.add_actor(actor)
      graph.actors.length.should eq 1
    end

    it 'can add movies' do
      graph.add_movie(movie)
      graph.movies.length.should eq 1
    end

    context 'returns nodes' do
      it 'returns a movie node' do
        graph.add_movie(movie).should be_a MovieNode
      end

      it 'returns an actor node' do
        graph.add_actor(actor).should be_a ActorNode
      end
    end

    context 'node already exists' do
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

  describe 'finding nodes' do
    it 'can find actors' do
      graph.add_actor(actor)
      graph.find_actor(actor).element.should == actor
    end

    it 'can find movies' do
      graph.add_movie(movie)
      graph.find_movie(movie).element.should == movie
    end

    context 'nodes not in graph' do
      it 'returns nil' do
        graph.find_movie(movie).should be_nil
      end

      it 'returns a node' do
        graph.add_movie(movie)
        graph.find_movie(movie).should be_a MovieNode
      end
    end
  end

end
