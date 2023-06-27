require "faraday"
require "faraday_middleware"
require "i18n"

module Phrase
  module Ota
    class Backend < I18n::Backend::Simple
      def initialize
        @current_version = nil
        start_polling
      end

      def available_locales
        Phrase::Ota.config.available_locales
      end

      def init_translations
        @translations = {}
        @initialized = true
      end

      protected

      def start_polling
        Thread.new do
          loop do
            sleep(Phrase::Ota.config.poll_interval_seconds)
            update_translations
          end
        end
      end

      def update_translations
        Phrase::Ota.config.logger.info("Phrase: Updating translations...")

        available_locales.each do |locale|
          url = "#{Phrase::Ota.config.base_url}/#{Phrase::Ota.config.distribution_id}/#{Phrase::Ota.config.secret_token}/#{locale}/yml"
          params = {
            app_version: Phrase::Ota.config.app_version,
            client: "ruby",
            sdk_version: Phrase::Ota::VERSION
          }
          params[:current_version] = @current_version unless @current_version.nil?

          connection = Faraday.new do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter Faraday.default_adapter
          end

          Phrase::Ota.config.logger.info("Phrase: Fetching URL: #{url}")

          response = connection.get(url, params, {"User-Agent" => "phrase-ota-rails #{Phrase::Ota::VERSION}"})
          next unless response.status == 200

          @current_version = CGI.parse(URI(response.env.url).query)["version"].first.to_i
          yaml = YAML.safe_load(response.body)
          yaml.each do |yaml_locale, tree|
            store_translations(yaml_locale, tree || {})
          end
        end
      end
    end
  end
end
