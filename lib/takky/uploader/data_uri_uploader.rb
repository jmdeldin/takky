module Takky
  module Uploader
    class DataUriUploader < AbstractUploader
      def initialize(attachment_class, attachment_id, data_uri)
        super(attachment_class, attachment_id)

        @file = file_from_data_uri(data_uri)
      end

      def file_from_data_uri(uri)
        header = "data:image/jpeg;base64,"
        return nil if uri.to_s.size < header.size

        body = uri.sub(header, "").strip

        tf = Tempfile.open(%w(file .jpg), encoding: "ascii-8bit")
        tf.print Base64.decode64(body)
        tf.rewind

        tf
      end
    end
  end
end
