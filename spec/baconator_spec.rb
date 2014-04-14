require 'spec_helper'

describe Bacon::Ator do
  let(:graph) { Graph.new }

  let(:jd) { mock_model(Actor, name: "Johnny Depp", bacon_link: nil).as_null_object }
  let(:mr) { mock_model(Actor, name: "Micky Rourke", bacon_link: nil).as_null_object }
  let(:kb) { mock_model(Actor, name: "Kevin Bacon", bacon_link: nil).as_null_object }
  let(:pc) { mock_model(Actor, name: "Penelope Cruz", bacon_link: nil).as_null_object }

  let(:mexico) { mock_model(Movie, { name: "Once Upon A Time In Mexico", bacon_link: nil }).as_null_object }
  let(:diner)  { mock_model(Movie, { name: "Diner", bacon_link: nil }).as_null_object }

  let(:baconator) { Bacon::Ator.new(graph) }

  before { graph.add_actor(kb) }

  describe "path calculation" do
    before do
      Actor.stub_chain(:where, :first).and_return(kb)

      graph.add_actor(jd)
      graph.add_actor(mr)

      graph.add_movie(mexico)
      graph.add_movie(diner)

      graph.connect(jd, mexico)
      graph.connect(mr, mexico)
      graph.connect(mr, diner)
      graph.connect(kb, diner)
    end

    it "traverses a simple graph to find a link" do
      path = baconator.calculate_path(jd)
      path.length.should eq 5
    end

    it "saves the path on all nodes" do
      jd.should_receive(:update_attribute).with(:bacon_link_id, mexico.id)
      mexico.should_receive(:update_attribute).with(:bacon_link_id, mr.id)
      mr.should_receive(:update_attribute).with(:bacon_link_id, diner.id)
      diner.should_receive(:update_attribute).with(:bacon_link_id, kb.id)
      kb.should_not_receive(:update_attribute)

      baconator.calculate_path(jd)
    end

    it "traverses using bacon links when possible" do
      graph.add_actor(pc)
      graph.connect(pc, mexico)
      graph.connect(pc, diner)

      path = baconator.calculate_path(pc)

      path.length.should eq 3
    end
  end

  it 'bacons' do
    node = Bacon::Node.create(graph.find_actor(kb), 0)
    node.should be_bacon
  end
end
