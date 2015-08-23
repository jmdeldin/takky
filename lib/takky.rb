require "takky/config"
require "sidekiq"

module Takky
  VERSION = "0.0.0"

  def self.config
    @config
  end

  def self.config=(config)
    @config = config
  end

  def self.configure
    @config = Takky::Config.new
    yield(@config)
  end

  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  autoload :Compression, "takky/compression"
  autoload :CompressionWorker, "takky/compression_worker"

  autoload :DeleteWorker, "takky/delete_worker"
  autoload :MimeType, "takky/mime_type"
  autoload :Model, "takky/model"
  autoload :Path, "takky/path"
  autoload :PostProcessor, "takky/post_processor"
  autoload :ResizeWorker, "takky/resize_worker"
  autoload :S3, "takky/s3"
  autoload :Uploader, "takky/uploader"
  autoload :UploadWorker, "takky/upload_worker"
  autoload :Url, "takky/url"
end
