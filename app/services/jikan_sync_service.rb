# app/services/jikan_sync_service.rb
class JikanSyncService
  BASE_URL    = "https://api.jikan.moe/v4"
  MAX_RETRIES = 3
  RATE_DELAY  = 0.4
  RETRY_AFTER = 60

  def self.import_top_animes(pages: 5)
    new.import_top_animes(pages: pages)
  end

  def import_top_animes(pages:)
    imported = 0
    errors   = []

    pages.times do |i|
      page = i + 1
      Rails.logger.info "[Jikan] Fetching page #{page}/#{pages}..."

      data = fetch_with_retry("/top/anime", { page: page })
      next if data.nil?

      data.each do |item|
        upsert_anime(item)
        imported += 1
      rescue => e
        errors << { mal_id: item["mal_id"], error: e.message }
        Rails.logger.warn "[Jikan] Skipped mal_id=#{item["mal_id"]}: #{e.message}"
      end

      sleep RATE_DELAY
    end

    Rails.logger.info "[Jikan] Done. #{imported} imported, #{errors.size} errors."
    { imported: imported, errors: errors }
  end

  private

  def fetch_with_retry(path, params = {}, attempt: 1)
    response = HTTParty.get(
      "#{BASE_URL}#{path}",
      query:   params,
      timeout: 10,
      headers: { "User-Agent" => "AnimeSearch/1.0" }
    )

    case response.code
    when 200
      JSON.parse(response.body)["data"]
    when 429
      wait = response.headers["retry-after"]&.to_i || RETRY_AFTER
      Rails.logger.warn "[Jikan] 429 — waiting #{wait}s..."
      sleep wait
      attempt <= MAX_RETRIES ? fetch_with_retry(path, params, attempt: attempt + 1) : nil
    when 500, 503
      wait = [2 ** attempt, 30].min
      Rails.logger.warn "[Jikan] #{response.code} — backoff #{wait}s (attempt #{attempt}/#{MAX_RETRIES})"
      sleep wait
      attempt <= MAX_RETRIES ? fetch_with_retry(path, params, attempt: attempt + 1) : nil
    else
      Rails.logger.error "[Jikan] Unexpected #{response.code} on #{path}"
      nil
    end
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    Rails.logger.warn "[Jikan] Timeout: #{e.message} (attempt #{attempt})"
    attempt <= MAX_RETRIES ? fetch_with_retry(path, params, attempt: attempt + 1) : nil
  end

  def upsert_anime(item)
    anime = Anime.find_or_initialize_by(mal_id: item["mal_id"])

    anime.assign_attributes(
      title:         item["title"],
      title_english: item["title_english"],
      synopsis:      item["synopsis"],
      score:         item["score"],
      year:          item["year"],
      image_url:     item.dig("images", "jpg", "image_url"),
      episodes:      item["episodes"],
      status:        item["status"]
    )

    anime.save_without_index!

    sync_associations(anime, item["genres"]  || [], Genre)
    sync_associations(anime, item["studios"] || [], Studio)
  end

  def sync_associations(anime, items, model)
    records = items.map do |item|
      model.find_or_create_by!(mal_id: item["mal_id"]) do |r|
        r.name = item["name"]
      end
    end

    existing_ids = anime.send(model.name.downcase.pluralize).pluck(:id)
    new_records  = records.reject { |r| existing_ids.include?(r.id) }
    anime.send(model.name.downcase.pluralize) << new_records if new_records.any?
  end
end
