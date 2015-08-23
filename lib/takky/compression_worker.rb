require "sidekiq/worker"

module Takky
  class CompressionWorker
    UnknownExtension = Class.new(StandardError)

    include Sidekiq::Worker

    def perform(class_name, image_id, quality,
                uploader_class = Takky::Uploader::FileUploader)
      klass = class_name.constantize
      record = klass.find(image_id)

      tf = Tempfile.open(["compressed", "." + record.extension], encoding: "ascii-8bit")
      compress(record, quality, tf)

      Takky.logger.info "[staple] compressing: #{class_name} id=#{image_id}"

      uploader = uploader_class.new(class_name, image_id, tf)
      uploader.run
    end

    private

    def compress(record, quality, tf)
      compresser = case record.extension
                   when "jpg"
                     Takky::Compression::JpegCompression.new(record, quality, tf)
                   when "png"
                     Takky::Compression::PngCompression.new(record, quality, tf)
                   else
                     fail(UnknownExtension, "No compresser for #{record.extension}")
                   end

      compresser.compress
    end
  end
end
