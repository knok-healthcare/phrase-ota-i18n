describe I18n::Backend::PhraseOta do
  context "#available_locales" do
    backend = I18n::Backend::PhraseOta.new

    it do
      expect(backend.available_locales).to(eq([]))
    end
  end
end
