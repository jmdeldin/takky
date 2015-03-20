require "spec_helper"

describe Takky::Url do
  include TakkySupport

  let(:img) {
    instance_double("Attachment", id: 8, environment: "t", filename: "secret.jpg")
  }

  around do |example|
    default_takky_config(example)
  end

  subject(:url) { described_class.new(img) }

  describe "#to_s" do
    let(:s3_path) { "img/t/#{img.id}/#{img.filename}" }

    it "returns an empty string if the filename is blank" do
      expect(described_class.new(OpenStruct.new).to_s).to eql ""
    end

    it "returns a URL for the original image" do
      exp_url = "//cdn.example.com/#{s3_path}"
      expect(url.to_s(cdn: true)).to eql exp_url
    end

    it "returns a non-CDN URL if requested" do
      exp_url = "//s3.example.com/bucket/#{s3_path}"
      expect(url.to_s(cdn: false)).to eql exp_url
    end

    context "with a protocol" do
      let(:exp_url) { "http://s3.example.com/bucket/#{s3_path}" }
      it "automatically adds a colon" do
        expect(url.to_s(protocol: "http")).to eql exp_url
      end

      it "handles colons" do
        expect(url.to_s(protocol: "http:")).to eql exp_url
      end
    end
  end
end
