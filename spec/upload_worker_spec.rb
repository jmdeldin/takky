require "spec_helper"

describe Takky::UploadWorker do
  include TakkySupport

  around do |example|
    default_takky_config(example)
  end

  describe "#perform", integration: true do
    let(:attachment) {
      Attachment.create!(extension: "jpg", style: "source")
    }
    let(:fonzi) { Rails.root.join("spec/fixtures/images/fonzi.jpg").to_s }
    let(:s3_path) { "img/t/#{attachment.id}/5b77362cf0.jpg" }

    it "sets the digest" do
      expect(subject).to receive(:upload).with(fonzi, s3_path)

      subject.perform("Attachment", attachment.id, fonzi)

      attachment.reload
      expect(attachment.digest.length).to eql 10
    end

    it "sets the URL" do
      expect(subject).to receive(:upload).with(fonzi, s3_path)

      subject.perform("Attachment", attachment.id, fonzi)

      attachment.reload
      expect(attachment.url(cdn: false)).to include("s3.example.com/bucket/#{s3_path}")
    end

    xit "deletes the previous attachment" do
      # first upload
      expect(subject).to receive(:upload).with(fonzi, s3_path)
      subject.perform("Attachment", attachment.id, fonzi)
      attachment.reload

      # second upload
      slide = Rails.root.join("spec/fixtures/images/hero_slide.jpg").to_s
      new_s3_path = "img/t/#{attachment.id}/#{subject.digest(slide)}.jpg"
      expect(subject).to receive(:upload).with(slide, new_s3_path)
      expect(Takky::DeleteWorker).to receive(:perform_in).with(5.minutes, s3_path)

      subject.perform("Attachment", attachment.id, slide)
      attachment.reload

      expect(attachment.url(cdn: false)).to include("s3.amazonaws.com/clymb/#{new_s3_path}")
    end
  end

  describe "#post_process" do
    let(:attachment) { Attachment.new }

    it "requires a hash" do
      expect {
        subject.post_process(attachment,
                             "post_process_with" => ["TakkySupport::FakeProcessor"])
      }.to raise_error(ArgumentError, "post_process_with must be a hash")
    end

    it "runs if the post_process_with key is set" do
      expect(attachment).to receive(:id).twice { 1 }
      expect(attachment).to receive(:url).twice { "//net.web/thing.jpg" }
      url = attachment.url

      args = {"quality" => 90}
      expect(TakkySupport::FakeProcessor).to receive(:perform_async).
        with("Attachment", 1, url, args)
      expect(TakkySupport::OtherProcessor).to receive(:perform_async).
        with("Attachment", 1, url, args)

      opts = {"post_process_with" => {"TakkySupport::FakeProcessor" => args,
                                      "TakkySupport::OtherProcessor" => args,
                                     }}
      subject.post_process(attachment, opts)
    end

    it "works with a single post processor" do
      expect(attachment).to receive(:id) { 1 }
      expect(attachment).to receive(:url).twice { "//example.com/foo.jpg" }
      expect(TakkySupport::FakeProcessor).to receive(:perform_async).
        with("Attachment", 1, attachment.url, {}) { "jid" }

      subject.post_process(attachment,
                           "post_process_with" => {"TakkySupport::FakeProcessor" => {}})
    end

    it "does not run without the key" do
      expect(subject.post_process(attachment, {})).to equal nil
    end
  end

  describe "#upload" do
    specify do
      opts = {write_opts: {cache_control: "max-age=#{3.days.seconds}"}}
      s3_mock = instance_double(Takky::S3)
      expect(s3_mock).to receive(:upload).with("/tmp/foo.jpg", "test.jpg", opts)

      worker = described_class.new(s3_mock)
      worker.upload("/tmp/foo.jpg", "test.jpg")
    end
  end

  describe "#digest" do
    specify do
      Tempfile.create(%w(foo .jpg)) do |tf|
        tf.puts "HI"
        tf.rewind

        expect(subject.digest(tf.path)).to eql "f712374589"
      end
    end
  end

  describe "#delete_previous_version" do
    it "deletes the previous version if present" do
      path = instance_double("Takky::Path", to_s: "img/t/foo.jpg")
      img = instance_double("Attachment", path: path, uploaded?: true)
      expect(Takky::DeleteWorker).to receive(:perform_in).with(5.minutes, path.to_s)
      subject.delete_previous_version(img)
    end

    it "does not delete if previous version is not present" do
      img = instance_double("Attachment", path: nil, uploaded?: false)
      expect(Takky::DeleteWorker).not_to receive(:perform_in)
      subject.delete_previous_version(img)
    end
  end
end
