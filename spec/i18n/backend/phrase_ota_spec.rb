describe I18n::Backend::PhraseOta do
  context "#available_locales" do
    I18n::Backend::PhraseOta.configure do |config|
      config.available_locales = [:en, :de]
    end

    subject { I18n::Backend::PhraseOta.new }

    it do
      expect(subject.available_locales).to(eq([:en, :de]))
    end
  end
end
