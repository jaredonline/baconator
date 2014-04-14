# Helper method to traverse an actor's bacon path and format
# it for easy consumption.
#
# Returns an array of hashes, each with three keys:
#   :first -> the first actor in the set (the starting node)
#   :movie -> the movie that links them
#   :last  -> the last actor in the set (the one that jumps
#             to another movie)
#
class BaconLinkBuilder
  def self.full_bacon_path(actor)
    self.new(actor).full_path
  end

  def self.raw_bacon_path(actor)
    path = [actor]
    link = actor.bacon_link
    while link.present?
      path << link
      link = link.bacon_link
    end

    if path.length > 1 && path.last.name == "Kevin Bacon"
      path
    else
      nil
    end
  end

  attr_reader :actor

  def initialize(actor)
    @actor = actor
  end

  def full_path
    @full_path ||= calculate_full_path
  end

  private
  def calculate_full_path
    path = nil
    if (link = actor.bacon_link).present?
      temp_path = []
      node = {
        first: actor,
        movie: link,
        last: nil
      }

      while link.present?
        if link.is_a?(Actor)
          node[:last] = link
          temp_path << node

          node = {
            first: link,
            movie: link.bacon_link
          }
        end
        link = link.bacon_link
      end

      if temp_path.last[:last].name == "Kevin Bacon"
        path = temp_path
      end
    end

    path || []
  end
end
