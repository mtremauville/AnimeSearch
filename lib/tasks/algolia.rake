# lib/tasks/algolia.rake
namespace :algolia do
  desc "Configure replica indexes for sorting"
  task setup_replicas: :environment do
    client = Algolia::SearchClient.create(
      ENV["ALGOLIA_APP_ID"] || Rails.application.credentials.dig(:algolia, :application_id),
      ENV["ALGOLIA_API_KEY"] || Rails.application.credentials.dig(:algolia, :api_key)
    )

    client.set_settings("animes_by_year_desc", {
      ranking: ["desc(year)", "desc(score)", "typo", "geo", "words",
                "filters", "proximity", "attribute", "exact", "custom"]
    })

    client.set_settings("animes_by_score_asc", {
      ranking: ["asc(score)", "typo", "geo", "words",
                "filters", "proximity", "attribute", "exact", "custom"]
    })

    puts "Replicas configured."
  end
end
