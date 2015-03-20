require "spec_helper"

describe Takky do
  include TakkySupport

  describe ".configure" do
    def set_and_test(key, value)
      Takky.configure { |c| c[key] = value }
      expect(Takky.config[key]).to eql value
    end

    around do |example|
      default_takky_config(example)
    end

    specify { set_and_test("cdn_host", "cdn.example.com") }
    specify { set_and_test("src_host", "s3.example.com/bucket") }
  end
end
