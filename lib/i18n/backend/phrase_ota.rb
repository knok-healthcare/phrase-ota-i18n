require 'i18n/backend/base'
require 'faraday'
require 'faraday_middleware'

module I18n
  module Backend
    class PhraseOta
      autoload :Configuration, 'i18n/backend/phrase_ota/configuration'

      class << self
        def configure
          yield(config) if block_given?
        end

        def config
          @config ||= Configuration.new
        end
      end

      def initialize
        start_polling
      end

      module Implementation
        include Base, Flatten

        def store_translations(locale, data, options = EMPTY_HASH)
          # TODO: Do we need this?
          # if I18n.enforce_available_locales &&
          #   I18n.available_locales_initialized? &&
          #   !I18n.locale_available?(locale)
          #   return data
          # end

          locale = locale.to_sym
          translations[locale] ||= Concurrent::Hash.new
          data = data.deep_symbolize_keys
          translations[locale].deep_merge!(data)
        end

        # TODO: Implement
        def available_locales
          [:en, :de]
        end

        def reload!
          @translations = nil
          self
        end

        def initialized?
          !@translations.nil?
        end

        def init_translations
          @translations = {}
        end

        def translations(do_init: false)
          init_translations if do_init || !initialized?
          @translations ||= {}
        end

      protected

        def lookup(locale, key, scope = [], options = EMPTY_HASH)
          init_translations unless initialized?
          keys = I18n.normalize_keys(locale, key, scope, options[:separator])

          keys.inject(translations) do |result, _key|
            return nil unless result.is_a?(Hash)
            unless result.has_key?(_key)
              _key = _key.to_s.to_sym
              return nil unless result.has_key?(_key)
            end
            result = result[_key]
            result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)
            result
          end
        end

        def start_polling
          Thread.new do
            until stop_polling?
              sleep(PhraseOta.config.poll_interval_seconds)
              update_translations
            end
          end
        end

        def stop_polling?
          false
        end

        def update_translations
          PhraseOta.config.logger.info("Updating translations...")

          available_locales.each do |locale|
            url = "http://localhost:8081/#{PhraseOta.config.distribution_id}/#{PhraseOta.config.secret_token}/#{locale.to_s}/yml"
            params = {
              app_version: PhraseOta.config.app_version,
              client: "Phrase-OTA-Rails",
              sdk_version: Phrase::Ota::Rails::VERSION,
            }
            connection = Faraday.new do |faraday|
              faraday.use FaradayMiddleware::FollowRedirects
              faraday.adapter Faraday.default_adapter
            end

            PhraseOta.config.logger.info("Fetching URL: #{url}")

            response = connection.get(url, params, { 'User-Agent' => "Phrase-OTA-Rails #{Phrase::Ota::Rails::VERSION}" })
            yaml = YAML.load(response.body)
            yaml.each do |yaml_locale, tree|
              store_translations(yaml_locale, tree || {})
            end
          end
        end
      end

      include Implementation
    end
  end
end
