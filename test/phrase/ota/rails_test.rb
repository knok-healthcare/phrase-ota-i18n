require "test_helper"

class Phrase::Ota::RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Phrase::Ota::Rails::VERSION
  end
end
