describe I18n::Backend::Configuration do
  context "#ota_base_url" do
    it do
      expect(I18n::Backend::PhraseOta.config.ota_base_url).to(eq("https://ota.phraseapp.com"))
    end
  end
end
