require 'spec_helper'

describe Bacon::Ator do
  it "traverses a simple graph to find a link" do
    jd = mock_model(Actor, name: "Johnny Depp", bacon_link: nil).as_null_object
    mr = mock_model(Actor, name: "Micky Rourke", bacon_link: nil).as_null_object
    kb = mock_model(Actor, name: "Kevin Bacon", bacon_link: nil).as_null_object

    mex_actors = [jd, mr]
    din_actors = [mr, kb]

    mex_actors.stub_chain(:where, :all).and_return(mex_actors)
    din_actors.stub_chain(:where, :all).and_return(din_actors)

    Actor.stub_chain(:where, :first).and_return(kb)

    mexico = mock_model(
      Movie, {
        name:   "Once Upon A Time In Mexico",
        actors: mex_actors,
        bacon_link: nil
      }
    ).as_null_object
    diner  = mock_model(
      Movie, {
        name:   "Diner",
        actors: din_actors,
        bacon_link: nil
      }
    ).as_null_object

    jd_movies = [mexico]
    mr_movies = [mexico, diner]
    kb_movies = [diner]

    jd.should_receive(:update_attribute).with(:bacon_link_id, mexico.id)
    mexico.should_receive(:update_attribute).with(:bacon_link_id, mr.id)
    mr.should_receive(:update_attribute).with(:bacon_link_id, diner.id)
    diner.should_receive(:update_attribute).with(:bacon_link_id, kb.id)
    kb.should_not_receive(:update_attribute)

    jd_movies.stub_chain(:where, :all).and_return(jd_movies)
    mr_movies.stub_chain(:where, :all).and_return(mr_movies)
    kb_movies.stub_chain(:where, :all).and_return(kb_movies)

    jd.stub(:movies).and_return(jd_movies)
    mr.stub(:movies).and_return(mr_movies)
    kb.stub(:movies).and_return(kb_movies)

    baconator = Bacon::Ator.new
    path      = baconator.calculate_path(jd)

    path.length.should eq 5
  end

  it "traverses using bacon links when possible" do
    kb = mock_model(Actor, name: "Kevin Bacon", bacon_link: nil).as_null_object

    diner  = mock_model(
      Movie, {
        name:   "Diner",
        bacon_link: kb
      }
    ).as_null_object

    mr = mock_model(Actor, name: "Micky Rourke", bacon_link: diner).as_null_object

    mexico = mock_model(
      Movie, {
        name:   "Once Upon A Time In Mexico",
        bacon_link: mr
      }
    ).as_null_object

    jd = mock_model(Actor, name: "Johnny Depp", bacon_link: mexico).as_null_object
    pc = mock_model(Actor, name: "Penelope Cruz", bacon_link: nil).as_null_object

    mex_actors = [jd, mr, pc]
    din_actors = [mr, kb, pc]

    mex_actors.stub_chain(:where, :all).and_return(mex_actors)
    din_actors.stub_chain(:where, :all).and_return(din_actors)

    diner.stub(:actors).and_return(din_actors)
    mexico.stub(:actors).and_return(mex_actors)

    Actor.stub_chain(:where, :first).and_return(kb)

    jd_movies = [mexico]
    mr_movies = [mexico, diner]
    kb_movies = [diner]
    pc_movies = [mexico, diner]

    jd.stub(:movies).and_return(jd_movies)
    mr.stub(:movies).and_return(mr_movies)
    kb.stub(:movies).and_return(kb_movies)
    pc.stub(:movies).and_return(pc_movies)

    baconator = Bacon::Ator.new
    path      = baconator.calculate_path(pc)

    path.length.should eq 3
  end

  it 'bacons' do
    kb = mock_model(Actor, name: "Kevin Bacon")

    node = Bacon::Node.create(kb, 0)
    node.should be_bacon
  end
end
