require "mini_magick"

module Takky
  class ResizeWorker
    include Sidekiq::Worker

    def perform(class_name, id, source_url, opts = {},
                uploader_class = Takky::Uploader::FileUploader)
      parse_args(class_name, id, source_url, opts)
      return if invalid?

      fetch_attachment
      upload(uploader_class, resized_upload)

      Takky.logger.info "[staple] resized #{@class_name}##{@id} (#{str_dims}) from #{@source_url}"
    end

    private

    def str_dims
      @dims.join("x")
    end

    def resized_upload
      tf = Tempfile.open([@style, "." + @extension])

      img = MiniMagick::Image.open(@source_url)
      img.resize str_dims
      img.quality @quality
      img.strip
      img.write(tf.path)
      tf.rewind
      tf
    end

    def upload(uploader_class, tf)
      uploader = uploader_class.new(@class_name, @id, tf)
      uploader.run
    end

    def parse_args(class_name, id, source_url, opts)
      @class_name = class_name
      @id = id
      @source_url = source_url.sub(%r{\A//}, "http://")
      @extension = File.extname(@source_url)
      @style = opts.fetch("style").to_s
      @dims = opts.fetch("dims")
      @quality = opts.fetch("quality")
    end

    def invalid?
      invalid_url? || invalid_dims?
    end

    def invalid_url?
      if URI(@source_url).class == URI::Generic
        raise ArgumentError, "#{@source_url} is invalid"
      end
    end

    def invalid_dims?
      if !@dims.is_a?(Array) || @dims.length != 2
        raise ArgumentError, "dims must be an array of [width, height]"
      end
    end

    def fetch_attachment
      @attachment = @class_name.constantize.find(@id)
    end
  end
end
