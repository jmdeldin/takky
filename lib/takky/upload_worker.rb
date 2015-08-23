require "sidekiq/worker"

module Takky
  class UploadWorker
    include Sidekiq::Worker

    # force uploads to happen on the server they started on
    if ENV['RACK_ENV']
      sidekiq_options queue: `hostname`.strip
    end

    def initialize(s3 = Takky::S3.new)
      @s3 = s3
    end

    def perform(class_name, attachment_id, src, opts = {})
      klass = class_name.constantize
      attachment = klass.find(attachment_id)

      # TODO: re-enable once we know why the wrong images are being deleted
      # delete_previous_version(attachment)
      attachment.digest = digest(src)
      upload(src.to_s, attachment.path.to_s)

      attachment.uploaded!
      post_process(attachment, opts)

      attachment
    end

    def upload(src, dest, max_age: 3.days.seconds)
      @s3.upload(src, dest, write_opts: {cache_control: "max-age=#{max_age}"})
    end

    def digest(file)
      Digest::SHA256.hexdigest(File.read(file))[0, 10]
    end

    def delete_previous_version(attachment)
      if attachment.uploaded?
        old_path = attachment.path.to_s
        DeleteWorker.perform_in(5.minutes, old_path)
      end
    end

    def post_process(attachment, opts)
      processors = opts["post_process_with"]
      return unless processors
      raise ArgumentError, "post_process_with must be a hash" if !processors.is_a?(Hash)

      url = attachment.url(cdn: false)
      processors.map { |class_name, args|
        klass = class_name.constantize
        klass.perform_async(attachment.class.to_s, attachment.id, url, args)
      }
    end
  end
end
