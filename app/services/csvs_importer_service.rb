class CsvsImporterService
  class ImportError < StandardError; end

  def initialize(movies_file, reviews_file)
    @movies_file = File.join(Rails.root, "tmp", movies_file)
    @reviews_file = File.join(Rails.root, "tmp", reviews_file)
  end

  def import
    validate_files!

    ActiveRecord::Base.transaction do
      movies = MoviesCsvImporter.new(@movies_file).import
      ReviewsCsvImporter.new(@reviews_file, movies).import
    end

    { success: true, message: "Import completed successfully!" }
  rescue StandardError => e
    Rails.logger.error("Import failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    { success: false, message: e.message }
  end

  private

  def validate_files!
    raise ImportError, "Movies file not found in tmp directory" unless File.exist?(@movies_file)
    raise ImportError, "Reviews file not found in tmp directory" unless File.exist?(@reviews_file)
  end
end
