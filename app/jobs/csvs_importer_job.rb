class CsvsImporterJob < ApplicationJob
  queue_as :default

  def perform(movies_file, reviews_file)
    CsvsImporterService.new(movies_file, reviews_file).import
  end
end
