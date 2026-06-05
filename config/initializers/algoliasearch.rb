AlgoliaSearch.configuration = {
  application_id: ENV["ALGOLIA_APP_ID"] || Rails.application.credentials.dig(:algolia, :application_id),
  api_key:        ENV["ALGOLIA_API_KEY"] || Rails.application.credentials.dig(:algolia, :api_key)
}
