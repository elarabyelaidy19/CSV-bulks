class CsvsImporterService
  require "csv"

  def initialize(movies_file, reviews_file)
    @movies_file = File.join(Rails.root, "tmp", movies_file)
    @reviews_file = File.join(Rails.root, "tmp", reviews_file)
  end

  def import
    raise "Movies file not found in tmp directory" unless File.exist?(@movies_file)
    raise "Reviews file not found in tmp directory" unless File.exist?(@reviews_file)

    ActiveRecord::Base.transaction do
      import_movies_and_relations
      import_reviews
    end
  end

  private

  def import_movies_and_relations
    directors_hash = {}
    actors_hash = {}
    locations_hash = {}
    movies_hash = {}

    CSV.foreach(@movies_file, headers: true) do |row|
      directors_hash[row["Director"]] ||= Director.find_or_create_by!(name: row["Director"])
      actors_hash[row["Actor"]] ||= Actor.find_or_create_by!(name: row["Actor"])
      locations_hash[row["Filming location"]] ||= FilmingLocation.find_or_create_by!(name: row["Filming location"])

      unless movies_hash[row["Movie"]]
        movies_hash[row["Movie"]] = Movie.find_or_create_by!(
          title: row["Movie"],
          description: row["Description"],
          country: row["Country"]
        )
      end

      MovieActor.find_or_create_by!(
        movie_id: movies_hash[row["Movie"]].id,
        actor_id: actors_hash[row["Actor"]].id
      )

      MovieFilmingLocation.find_or_create_by!(
        movie_id: movies_hash[row["Movie"]].id,
        filming_location_id: locations_hash[row["Filming location"]].id
      )
    end
  end

  def import_reviews
    users_hash = {}
    movies_hash = Movie.pluck(:title, :id).to_h

    review_data = []
    CSV.foreach(@reviews_file, headers: true) do |row|
      users_hash[row["User"]] ||= User.find_or_create_by!(name: row["User"])

      review_data << {
        movie_id: movies_hash[row["Movie"]],
        user_id: users_hash[row["User"]].id,
        rating: row["Stars"],
        comment: row["Review"]
      }
    end

    Review.upsert_all(review_data, unique_by: [ :movie_id, :user_id ])
  end
end
