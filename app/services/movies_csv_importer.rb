class MoviesCsvImporter
  require "csv"

  REQUIRED_HEADERS = %w[Movie Description Director Actor Filming\ location Country].freeze

  def initialize(file_path)
    @file_path = file_path
    @movie_data = {}
    @actor_movie_pairs = []
    @location_movie_pairs = []
  end

  def import
    validate_headers!
    process_csv
    import_movie_relations
    Movie.where(title: @movie_data.values.map { |d| d[:title] }).index_by(&:title)
  end

  private

  def validate_headers!
    headers = CSV.read(@file_path, headers: true).headers
    missing_headers = REQUIRED_HEADERS - headers

    if missing_headers.any?
      raise CsvsImporterService::ImportError,
            "Missing movie headers: #{missing_headers.join(', ')}"
    end
  end

  def process_csv
    CSV.foreach(@file_path, headers: true) do |row|
      movie_key = row["Movie"].downcase

      @movie_data[movie_key] ||= {
        title: row["Movie"],
        description: row["Description"],
        country: row["Country"],
        director_name: row["Director"],
        actor_names: Set.new,
        location_names: Set.new
      }

      @movie_data[movie_key][:actor_names].add(row["Actor"])
      @movie_data[movie_key][:location_names].add(row["Filming location"])
    end
  end

  def import_movie_relations
    directors = bulk_upsert_records(Director, @movie_data.values.map { |d| d[:director_name] }.uniq)
    actors = bulk_upsert_records(Actor, @movie_data.values.flat_map { |d| d[:actor_names].to_a }.uniq)
    locations = bulk_upsert_records(FilmingLocation, @movie_data.values.flat_map { |d| d[:location_names].to_a }.uniq)

    movies = import_movies(directors)
    prepare_and_import_join_tables(movies, actors, locations)
  end

  def bulk_upsert_records(model, names)
    records = names.map { |name| { name: name } }
    model.upsert_all(records, unique_by: :name)
    model.where(name: names).index_by(&:name)
  end

  def import_movies(directors)
    movie_records = @movie_data.values.map do |data|
      {
        title: data[:title],
        description: data[:description],
        country: data[:country],
        director_id: directors[data[:director_name]]&.id
      }
    end

    Movie.upsert_all(movie_records, unique_by: :title)
    Movie.where(title: @movie_data.values.map { |d| d[:title] }).index_by(&:title)
  end

  def prepare_and_import_join_tables(movies, actors, locations)
    @movie_data.each do |_, data|
      movie = movies[data[:title]]
      next unless movie

      data[:actor_names].each do |actor_name|
        @actor_movie_pairs << {
          movie_id: movie.id,
          actor_id: actors[actor_name]&.id
        }
      end

      data[:location_names].each do |location_name|
        @location_movie_pairs << {
          movie_id: movie.id,
          filming_location_id: locations[location_name]&.id
        }
      end
    end

    import_join_tables
  end

  def import_join_tables
    MovieActor.upsert_all(
      @actor_movie_pairs.compact,
      unique_by: [ :movie_id, :actor_id ]
    )

    MovieFilmingLocation.upsert_all(
      @location_movie_pairs.compact,
      unique_by: [ :movie_id, :filming_location_id ]
    )
  end
end
