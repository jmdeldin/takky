require "minitest/autorun"
require "minitest/pride" unless ENV["TERM"] == "dumb"
require "takky"

class TestCase < MiniTest::Spec
  def described_class
    Kernel.const_get self.class.superclass.to_s.sub(/\ATest/, "Takky::")
  end
end
