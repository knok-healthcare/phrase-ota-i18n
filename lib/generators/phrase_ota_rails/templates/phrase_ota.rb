require 'i18n/backend/phrase_ota'

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::PhraseOta.new, I18n::Backend::Simple.new)

I18n::Backend::PhraseOta.configure do |config|
  # Phrase OTA Distribution ID
  config.distribution_id = "<%= options[:distribution_id] %>"

  # Your Phrase OTA secret token (either development or production)
  config.secret_token = "<%= options[:secret_token] %>"

  # Logger
  config.logger = Rails.logger

  # App version, set to nil if you do not want to use app version restriction
  config.app_version = nil
end
