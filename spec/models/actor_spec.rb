require 'spec_helper'

describe Actor do
  it '' do
    kb = mock_model(Actor, name: "Kevin Bacon",     bacon_link: nil)
    ut = mock_model(Movie, name: "U Turn",          bacon_link: kb)

    jp = Actor.new(name: "Joaquin Phoenix", bacon_link: ut)

    jp.full_bacon_path.length.should eq 1
  end

  it '' do
    kb = mock_model(Actor, name: "Kevin Bacon",     bacon_link: nil)
    ut = mock_model(Movie, name: "U Turn",          bacon_link: kb)
    jp = mock_model(Actor, name: "Joaquin Phoenix", bacon_link: ut)
    bb = mock_model(Movie, name: "Brother Bear",    bacon_link: jp)

    jc = Actor.new(name: "Joan Copeland", bacon_link: bb)


    jc.full_bacon_path.length.should eq 2
  end

  it '' do
    ut = mock_model(Movie, name: "U Turn",          bacon_link: nil)
    jp = mock_model(Actor, name: "Joaquin Phoenix", bacon_link: ut)
    bb = mock_model(Movie, name: "Brother Bear",    bacon_link: jp)

    jc = Actor.new(name: "Joan Copeland", bacon_link: bb)


    jc.full_bacon_path.length.should eq 0
  end
end
