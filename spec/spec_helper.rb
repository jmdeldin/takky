require "takky"

unless defined?(Rails)
  require "ostruct"
  require "active_support/string_inquirer"
  Rails = OpenStruct.new(env: ActiveSupport::StringInquirer.new("test"))
end

module TakkySupport
  class FakeAttachment
    def self.find(_id); new; end
  end

  class FakeProcessor
    def self.perform_async(_class_name, _id, *_args); fail; end
  end

  OtherProcessor = Class.new(FakeProcessor)


  # TODO: This needs to go in Takky's spec_helper file
  def default_takky_config(example)
    old_config = Takky.config

    Takky.configure do |c|
      c.cdn_host = "cdn.example.com"
      c.src_host = "s3.example.com/bucket"
    end

    example.run

    Takky.config = old_config
  end

  def image_fixture(filename)
    Pathname(__dir__).join("spec/fixtures/images", filename).to_s
  end

  def identical_files?(a, b)
    out = `compare -metric MAE #{a} #{b} null: 2>&1`
    status = $?.exitstatus
    fail out if $?.exitstatus == 2
    out.split(" ").first.to_f < 1 && status == 0
  end
end

module DatabaseSupport
  require "active_record"
  ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

  TABLE_NAME = "takky_model_attachments"

  ActiveRecord::Base.connection.tap do |cx|
    cx.create_table(TABLE_NAME) do |t|
      t.string :style, null: false
      t.string :digest, null: true
      t.string :extension, limit: 4, null: false
      t.string :environment, limit: 1, null: false
      t.datetime :uploaded_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end

  class ::TakkyModelAttachment < ActiveRecord::Base
    include Takky::Model
  end

  def fetch_next_attachment_id
    db = Rails.configuration.database_configuration.fetch("test").fetch("database")
    next_id_sql = <<-EOF
      SELECT `AUTO_INCREMENT`
      FROM information_schema.tables
      WHERE table_schema = '#{db}' AND table_name = '#{TABLE_NAME}'
    EOF

    ActiveRecord::Base.connection.select_value(next_id_sql)
  end
end
