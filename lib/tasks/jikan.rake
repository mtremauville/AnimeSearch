# lib/tasks/jikan.rake
namespace :jikan do
  desc "Import top animes from Jikan API"
  task :import, [:pages] => :environment do |_, args|
    pages = (args[:pages] || 5).to_i
    puts "Starting import — #{pages} pages (~#{pages * 25} animes)..."
    result = JikanSyncService.import_top_animes(pages: pages)
    puts "Import complete: #{result[:imported]} animes."
    result[:errors].each { |e| puts "  mal_id=#{e[:mal_id]}: #{e[:error]}" }
  end

  desc "Reindex all animes in Algolia"
  task reindex: :environment do
    puts "Reindexing #{Anime.count} animes..."
    Anime.reindex!
    puts "Done."
  end

  desc "Import + reindex"
  task :sync, [:pages] => [:import, :reindex]
end
