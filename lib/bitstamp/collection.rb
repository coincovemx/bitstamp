module Bitstamp
  class Collection
    attr_accessor :access_token, :module, :name, :model, :path, :base_path

    def initialize(api_prefix='/api')
      self.access_token = Bitstamp.key

      self.module    = self.class.to_s.singularize.underscore
      self.name      = self.module.split('/').last
      self.model     = self.module.camelize.constantize
      self.base_path = api_prefix || ''
      self.path      = "#{base_path}/#{name.pluralize}"
    end

    def all(options = {})
      Bitstamp::Helper.parse_objects! Bitstamp::Net.get(path).body, model
    end

    def create(options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.post(path, options).body, model
    end

    def find(id, options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.get("#{path}/#{id}").body, model
    end

    def update(id, options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.patch("#{path}/#{id}", options).body, model
    end
  end
end
