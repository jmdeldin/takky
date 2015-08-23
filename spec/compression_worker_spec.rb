require "spec_helper"

describe Takky::CompressionWorker do
  include DatabaseSupport

  describe "#perform" do
    let(:quality) { 85 }

    it "raises an error when given an unrecognized extension" do
      attachment = instance_double("TakkyModelAttachment", id: 1, extension: "tiff")
      expect(TakkyModelAttachment).to receive(:find).with(1) { attachment }

      expect {
        described_class.new.perform("TakkyModelAttachment", 1, quality)
      }.to raise_error(Takky::CompressionWorker::UnknownExtension)
    end

    it "resizes" do
      attachment = instance_double("TakkyModelAttachment", id: 1, extension: "jpg",
                                                 url: "//s3.amazonaws.com/img/t/1/hash.jpg")
      expect(TakkyModelAttachment).to receive(:find).with(1) { attachment }

      uploader = instance_double("Takky::Uploader::FileUploader", run: "jid")
      klass = class_double("Takky::Uploader::FileUploader", new: uploader)

      compresser = instance_double("Takky::Compression::JpegCompression",
                                   compress: "sometf")
      expect(Takky::Compression::JpegCompression).to receive(:new) { compresser }

      described_class.new.perform("TakkyModelAttachment", 1, quality, klass)
    end
  end
end
