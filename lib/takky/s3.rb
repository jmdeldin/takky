require "aws-sdk"

module Takky
  class S3
    attr_reader :bucket

    def initialize(bucket: Takky.config.bucket)
      @bucket = bucket
    end

    # @param [Pathname|String] src  local filename
    # @param [String]          dest target location on S3
    # @param [Symbol]          acl
    # @param [Hash]            write_opts See Aws::S3::Client#put_object for possible arguments
    def upload(src, dest, acl: 'public-read', write_opts: {})
      File.open(src, 'rb') do |fh|
        opts = {acl: acl,
                body: fh,
                bucket: @bucket,
                content_type: content_type(src),
                key: dest,
               }.merge(write_opts)

        # TODO: Note the 5 GB limit S3 has...somewhere
        s3.put_object(opts)
      end
    end

    def delete(path, directory: false)
      if directory
        objs = s3.list_objects(bucket: @bucket, prefix: path).
               contents.
               map(&:key).
               sort { |a,b| a.ends_with?('/') ? 1 : 0 }. # delete the directory last
               each_with_object({objects: []}) { |k, h| h[:objects] << {key: k} }
        s3.delete_objects(bucket: @bucket,
                           delete: objs)
      else
        s3.delete_object(bucket: @bucket, key: path)
      end
    end

    private

    def s3
      @s3 ||= Aws::S3::Client.new
    end

    def content_type(filename)
      mime = MIME::Types.type_for(filename.to_s)
      return nil if mime.blank?

      mime.first.content_type
    end
  end
end
