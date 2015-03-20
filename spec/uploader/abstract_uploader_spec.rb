require "spec_helper"

describe Takky::Uploader::AbstractUploader do
  include TakkySupport

  subject(:uploader) { described_class.new(TakkySupport::FakeAttachment, 1) }

  let(:tf) { Tempfile.new(%w(foo .jpg)) }
  let(:args) {
    ["TakkySupport::FakeAttachment",
     1,
     tf.path,
     {"post_process_with" => {"TakkySupport::FakeProcessor" => {"foo" => "bar"}}}]
  }

  after do
    tf.close
    tf.unlink
  end

  describe "#post_process_with" do
    it "appends post-processors uniquely" do
      uploader.post_process_with TakkySupport::FakeProcessor, "quality" => 99
      uploader.post_process_with TakkySupport::OtherProcessor
      uploader.post_process_with TakkySupport::FakeProcessor, "quality" => 10

      processors = {"TakkySupport::FakeProcessor" => {"quality" => 10},
                    "TakkySupport::OtherProcessor" => {}}

      expect(uploader.post_processors).to eql processors
    end
  end

  describe "#worker_args" do
    specify do
      uploader.post_process_with TakkySupport::FakeProcessor, "foo" => "bar"
      uploader.file = tf
      expect(uploader.worker_args).to eql args
    end
  end

  describe "#run" do
    before do
      uploader.post_process_with TakkySupport::FakeProcessor, "foo" => "bar"
      uploader.file = tf
    end

    it "uses perform_async if async=true" do
      uploader.async = true
      expect(Takky::UploadWorker).to receive(:perform_async).with(*args)
      uploader.run
    end

    it "instantiates the worker if synchronous" do
      worker = instance_double("Takky::UploadWorker")
      expect(Takky::UploadWorker).to receive(:new) { worker }
      expect(worker).to receive(:perform).with(*args)
      uploader.run
    end
  end
end
