require "faraday"
require "faraday_middleware"
require "i18n"

module Phrase
  module Ota
    class Backend < I18n::Backend::Simple
      def initialize
        @current_locale_versions = {}
        @initialized = true # initializing immeditaly as we don't want to wait until all OTA translations have been fetched
        start_polling
      end

      def available_locales
        Phrase::Ota.config.available_locales
      end

      def init_translations
      end

      protected

      def start_polling
        Thread.new do
          loop do
            sleep(Phrase::Ota.config.poll_interval)
            update_translations
          end
        end
      end

      def update_translations
        log("Updating translations...")

        available_locales.each do |locale|
          params = {
            app_version: Phrase::Ota.config.app_version,
            client: "ruby",
            sdk_version: Phrase::Ota::VERSION
          }
          current_version = @current_locale_versions[locale]
          params[:current_version] = current_version unless current_version.nil?

          connection = Faraday.new do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter Faraday.default_adapter
          end

          uri = URI("#{Phrase::Ota.config.base_url}/#{Phrase::Ota.config.distribution_id}/#{Phrase::Ota.config.secret_token}/#{locale}/yml")
          uri.query = URI.encode_www_form(params)
          url = uri.to_s
          log("Request URL: #{url}")

          response = connection.get(url, {}, {"User-Agent" => "phrase-ota-i18n #{Phrase::Ota::VERSION}"})
          next unless response.status == 200

          @current_locale_versions[locale] = CGI.parse(URI(response.env.url).query)["version"].first.to_i
          yaml = YAML.safe_load(response.body)
          yaml.each do |yaml_locale, tree|
            store_translations(locale, tree || {})
            log("Updated locale: #{locale}")
          end
        end
      end

      def log(message)
        Phrase::Ota.config.logger.info("Phrase OTA: #{message}") if Phrase::Ota.config.debug
      end
    end
  end
end
