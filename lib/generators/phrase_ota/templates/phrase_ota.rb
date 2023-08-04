require "phrase/ota"

fallback_backend = I18n::Backend::Simple.new

Phrase::Ota.configure do |config|
  # Possible datacenter values are "eu" and "us". The distribution_id and secret_token need to match the datacenter
  config.datacenter = "eu"

  # Phrase OTA Distribution ID
  config.distribution_id = "<%= options[:distribution_id] %>"

  # Your Phrase OTA secret token (either development or production)
  config.secret_token = "<%= options[:secret_token] %>"

  # Logger
  config.logger = Rails.logger

  # App version, set to nil if you do not want to use app version restriction
  config.app_version = nil

  # Available locales that will be updated over-the-air
  config.available_locales = fallback_backend.available_locales
end

I18n.backend = I18n::Backend::Chain.new(Phrase::Ota::Backend.new, fallback_backend)
