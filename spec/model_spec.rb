require "spec_helper"

describe TakkyModelAttachment do
  include TakkySupport
  include DatabaseSupport

  subject(:attachment) { TakkyModelAttachment.new(style: "source", extension: "jpg") }
  let(:blank) { TakkyModelAttachment.new }

  describe "#style" do
    it "is required" do
      expect(blank).not_to be_valid
      expect(blank.errors[:style]).to include "can't be blank"
    end

    it "is stripped of extra spaces" do
      blank.style = "  foo \t "
      blank.valid?
      expect(blank.style).to eql "foo"
      blank.style = :foo
      expect(blank.style).to eql "foo"
    end
  end

  describe "#path" do
    it "is nil for new records" do
      expect(attachment.path).to be_nil
    end

    it "returns the path", type: :integration do
      attachment.digest = "bighash"
      attachment.save!
      expect(attachment.path.to_s).to eql "img/t/#{attachment.id}/bighash.jpg"
    end
  end

  describe "#extension" do
    it "cannot be greater than four characters" do
      i = described_class.create(extension: "pnggg")
      expect(i.errors[:extension]).to include "is too long (maximum is 4 characters)"
    end
  end

  describe "#environment" do
    it "changes on update" do
      attachment.save!

      # simulate existing production record
      described_class.connection.execute("UPDATE #{DatabaseSupport::TABLE_NAME} SET environment = 'p' WHERE id = #{attachment.id}")

      i = described_class.find(attachment.id)
      expect(i.environment).to eq "p"
      i.update_attributes(style: "thumb")
      expect(i.environment).to eq "t"
    end
  end

  describe "#uploaded?" do
    it "returns true if uploaded_at is set" do
      expect(described_class.new.tap { |i| i.uploaded_at = Time.now }).to be_uploaded
    end

    it "returns false if uploaded_at is not set" do
      expect(described_class.new).not_to be_uploaded
    end
  end

  describe "#url" do
    around do |example|
      default_takky_config(example)
    end

    before do
      attachment.digest = "ASDF314159"
      attachment.save!
    end

    it "handles no args and a cdn styleword arg" do
      path = attachment.path.to_s
      expect(attachment.url(cdn: true)).to match(%r{//.*cdn.example.com.*/#{path}})
      expect(attachment.url(cdn: false)).to match(%r{//.*s3.example.com.*/#{path}})
    end
  end

  describe "#filename" do
    it "is nil if the attachment is not saved" do
      expect(described_class.new.filename).to be_nil
    end

    it "returns the digest and extension" do
      attachment.digest = "somehash"
      attachment.save!
      expect(attachment.filename).to eql "#{attachment.digest}.#{attachment.extension}"
    end
  end

  describe "#delete_uploads", integration: true do
    before do
      attachment.tap { |i|
        i.uploaded_at = DateTime.current
      }
      attachment.save!
    end

    let(:img_path) { attachment.path.to_s }

    it "deletes the base directory" do
      expect(Takky::DeleteWorker).to receive(:perform_async).
        with(attachment.path.root.to_s, true)
      attachment.delete_uploads
    end
  end
end
