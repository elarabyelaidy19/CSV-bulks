class ReviewsCsvImporter
  require "csv"

  REQUIRED_HEADERS = %w[Movie User Stars Review].freeze
  BATCH_SIZE = 1000

  def initialize(file_path, movies)
    @file_path = file_path
    @movies = movies
  end

  def import
    validate_headers!
    process_reviews
  end

  private

  def validate_headers!
    headers = CSV.read(@file_path, headers: true).headers
    missing_headers = REQUIRED_HEADERS - headers

    if missing_headers.any?
      raise CsvsImporterService::ImportError,
            "Missing review headers: #{missing_headers.join(', ')}"
    end
  end

  def process_reviews
    user_names = Set.new
    user_review_map = {}

    CSV.foreach(@file_path, headers: true) do |row|
      movie_id = @movies[row["Movie"].downcase]&.id
      next unless movie_id

      user_names.add(row["User"])
      user_review_map[row["User"]] ||= []
      user_review_map[row["User"]] << {
        movie_id: movie_id,
        rating: row["Stars"],
        comment: row["Review"]
      }
    end

    import_users_and_reviews(user_names, user_review_map)
  end

  def import_users_and_reviews(user_names, user_review_map)
    User.upsert_all(
      user_names.map { |name| { name: name } }
    )
    users = User.where(name: user_names.to_a).index_by(&:name)
    review_data = []

    user_review_map.each do |user_name, reviews|
      user_id = users[user_name]&.id
      next unless user_id

      reviews.each do |review|
        review_data << review.merge(user_id: user_id)

        if review_data.size >= BATCH_SIZE
          upsert_reviews(review_data)
          review_data = []
        end
      end
    end

    upsert_reviews(review_data) if review_data.any?
  end

  def upsert_reviews(review_data)
    Review.upsert_all(review_data, unique_by: [ :movie_id, :user_id ])
  end
end
