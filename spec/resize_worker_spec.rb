require "spec_helper"

describe Takky::ResizeWorker do
  include TakkySupport

  let(:klass) { "TakkyModelAttachment" }
  let(:url) { "//example.com/test.jpg" }
  let(:opts) { {"quality" => 85, "style" => "child", "dims" => [50, 50]} }

  describe "validation" do
    it "requires a style" do
      expect {
        described_class.new.perform(klass, 1, url)
      }.to raise_error(KeyError, 'key not found: "style"')
    end

    it "requires dimensions" do
      expect {
        opts.delete("dims")
        described_class.new.perform(klass, 1, url, opts)
      }.to raise_error(KeyError, 'key not found: "dims"')
    end

    it "requires dimensions to be an ordered pair" do
      expect {
        described_class.new.perform(klass, 1, url, opts.merge("dims" => [1]))
      }.to raise_error(ArgumentError, "dims must be an array of [width, height]")

      expect {
        described_class.new.perform(klass, 1, url, opts.merge("dims" => "3x2"))
      }.to raise_error(ArgumentError, "dims must be an array of [width, height]")
    end
  end

  describe "#perform", integration: true do
    let(:attachment) {
      TakkyModelAttachment.create!(extension: "jpg", style: "parent")
    }

    it "works" do
      stub_request(:get, url).
        to_return(status: 200,
                  body: Rack::Test::UploadedFile.new(image_fixture("triangle.jpg"), "image/jpeg").read)

      log = "[staple] resized TakkyModelAttachment##{attachment.id} (50x50) from http:#{url}"
      expect(Takky.logger).to receive(:info).with(log)

      uploader = instance_double("Takky::Uploader::FileUploader", run: "jid")
      klass = class_double("Takky::Uploader::FileUploader", new: uploader)

      described_class.new.perform("TakkyModelAttachment", attachment.id, url, opts, klass)
    end
  end
end
