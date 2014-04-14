class Actor < ActiveRecord::Base
  # The -> { uniq } is Rails 4 scoping the association
  # between actors and movies to unique records. Fairly
  # arcane
  has_and_belongs_to_many :movies, -> { uniq }
  belongs_to :bacon_link, :class_name => "Movie", :foreign_key => :bacon_link_id

  def full_bacon_path
    if (link = self.bacon_link).present?
      path = []
      node = {
        first: self,
        movie: link,
        last: nil
      }

      while link.present?
        if link.is_a?(Actor)
          node[:last] = link
          path << node

          node = {
            first: link,
            movie: link.bacon_link
          }
        end
        link = link.bacon_link
      end

      if path.last[:last].name == "Kevin Bacon"
        path
      else
        []
      end
    else
      []
    end
  end
end
