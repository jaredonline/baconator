class Movie < ActiveRecord::Base
  # The -> { uniq } is Rails 4 scoping the association
  # between actors and movies to unique records. Fairly
  # arcane
  has_and_belongs_to_many :actors, -> { uniq }
  belongs_to :bacon_link, :class_name => "Actor", :foreign_key => :bacon_link_id
end
