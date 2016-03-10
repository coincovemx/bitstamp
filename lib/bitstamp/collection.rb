module Bitstamp
  class Collection
    attr_accessor :access_token, :module, :name, :model, :path

    def initialize(api_prefix="/api")
      self.access_token = Bitstamp.key

      self.module = self.class.to_s.singularize.underscore
      self.name   = self.module.split('/').last
      self.model  = self.module.camelize.constantize
      self.path   = "#{api_prefix}/#{self.name.pluralize}"
    end

    def all(options = {})
      Bitstamp::Helper.parse_objects! Bitstamp::Net.get(self.path).body, self.model
    end

    def create(options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.post(self.path, options).body, self.model
    end

    def find(id, options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.get("#{self.path}/#{id}").body, self.model
    end

    def update(id, options = {})
      Bitstamp::Helper.parse_object! Bitstamp::Net.patch("#{self.path}/#{id}", options).body, self.model
    end
  end
end
