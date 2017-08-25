module Bitstamp
  module Net
    HTTPI_ADAPTER = :net_http

    def self.to_uri(path)
      path = "/#{path}" if path[0] != '/'
      path = "/api/#{path}" unless path.include?('api/')
      'https://' + ("www.bitstamp.net#{path}" + '/').gsub('//', '/')
    end

    def self.req(verb, path, options={})
      path = build_path(path) if path.is_a?(Array)
      r = HTTPI::Request.new(self.to_uri(path))

      if Bitstamp.conn_timeout
        r.open_timeout = Bitstamp.conn_timeout
        r.read_timeout = Bitstamp.conn_timeout
      end

      if Bitstamp.configured?
        options[:key] = Bitstamp.key
        options[:nonce] = self.nonce_parameter
        options[:signature] = HMAC::SHA256.hexdigest(Bitstamp.secret, options[:nonce]+Bitstamp.client_id.to_s+options[:key]).upcase
      end

      r.body = options

      HTTPI.request(verb, r, HTTPI_ADAPTER)
    end

    def self.nonce_parameter
      Bitstamp.nonce_parameter
    end

    def self.get(path, options={})
      self.req(:get, path, options)
    end

    def self.post(path, options={})
      self.req(:post, path, options)
    end

    def self.patch(path, options={})
      self.req(:patch, path, options)
    end

    def self.delete(path, options={})
      self.req(:delete, path, options)
    end

    def self.build_path(array)
      array.delete_if{ |x| !x || x.nil?}.join('/')
    end
  end
end
