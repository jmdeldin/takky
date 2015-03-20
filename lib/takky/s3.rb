module Takky
  class S3
    attr_reader :bucket

    def initialize(bucket: Takky.config.bucket)
      s3 = AWS::S3.new
      @bucket = s3.buckets[bucket]
    end

    # @param [Pathname|String] src  local filename
    # @param [String]          dest target location on S3
    # @param [Symbol]          acl
    # @param [Hash]            write_opts See S3Object#write for possible arguments
    def upload(src, dest, acl: :public_read, write_opts: {})
      obj = bucket.objects[dest]
      opts = {acl: acl, content_type: content_type(src)}.merge(write_opts)
      obj.write(Pathname(src), opts)
    end

    def delete(path, directory: false)
      if directory
        bucket.objects.with_prefix(path).delete_all
      else
        bucket.objects[path].delete
      end
    end

    private

    def content_type(filename)
      mime = MIME::Types.type_for(filename.to_s)
      return nil if mime.blank?

      mime.first.content_type
    end
  end
end
