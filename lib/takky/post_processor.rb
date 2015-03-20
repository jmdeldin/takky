module Takky
  class PostProcessor
    include Sidekiq::Worker

    attr_reader :klass, :id, :parent_image, :source_url, :opts

    def perform(klass, id, source_url, opts = {})
      @klass = klass
      @id = id
      @parent_image = klass.constantize.find(id)
      @source_url = source_url
      @opts = opts

      run
    end

    def run
      fail NotImplementedError, "#{self.class} does not implement #run"
    end
  end
end
