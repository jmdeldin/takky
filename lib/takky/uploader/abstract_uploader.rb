module Takky
  module Uploader
    class AbstractUploader
      attr_accessor :async, :file
      attr_reader :attachment, :post_processors

      # @param [Class|String] attachment_class
      # @param [Fixnum] attachment_id
      def initialize(attachment_class, attachment_id)
        @async = false
        @attachment_class = attachment_class.to_s
        @attachment_id = attachment_id
        @attachment = @attachment_class.constantize.find(@attachment_id)
        @post_processors = {}
      end

      def worker_args
        [@attachment_class,
         @attachment_id,
         file.path,
         {"post_process_with" => post_processors}
        ]
      end

      def run
        if async
          Takky::UploadWorker.perform_async(*worker_args)
        else
          Takky::UploadWorker.new.perform(*worker_args)
        end
      end

      # Register a post-processor and optional arguments. This method may be
      # invoked multiple times.
      #
      # @param [Class] klass
      # @param [Hash]  args
      def post_process_with(klass, args = {})
        @post_processors[klass.to_s] = args
      end
    end
  end
end
