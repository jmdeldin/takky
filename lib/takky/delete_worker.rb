require "sidekiq/worker"

module Takky
  class DeleteWorker
    include Sidekiq::Worker

    def initialize(s3 = Takky::S3.new)
      @s3 = s3
    end

    def perform(path, is_directory = false)
      @s3.delete(path, directory: is_directory)
    end
  end
end
