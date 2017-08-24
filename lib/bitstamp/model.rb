module Bitstamp
  class Model
    attr_accessor :error, :message
    attr_accessor :base_path

    if ActiveModel::VERSION::MAJOR <= 3
      include ActiveModel::Validations
      include ActiveModel::Conversion
      extend ActiveModel::Naming

      def initialize(attributes = {})
        self.base_path = attributes.delete(:base_path) || 'api'
        self.attributes = attributes
      end
    else
      include ActiveModel::Model

      def initialize(attributes = {})
        self.base_path = attributes.delete(:base_path) || 'api'
        super(attributes)
      end
    end

    # Set the attributes based on the given hash
    def attributes=(attributes = {})
      attributes.each do |name, value|
        begin
          send("#{name}=", value)
        rescue NoMethodError
          puts "Unable to assign #{name}. No such method."
        end
      end
    end

    # Returns a hash with the current instance variables
    def attributes
      Hash[instance_variables.map { |name| [name, instance_variable_get(name)] }]
    end
  end
end
