
module SearchCop
  class Reflection
    attr_accessor :attributes, :options, :aliases, :scope, :sanitize

    def initialize
      self.attributes = {}
      self.options = {}
      self.aliases = {}
      self.sanitize = {}
    end

    def default_attributes
      keys = options.select { |key, value| value[:default] == true }.keys
      keys = attributes.keys.reject { |key| options[key] && options[key][:default] == false } if keys.empty?
      keys = keys.to_set

      attributes.select { |key, value| keys.include? key }
    end
  end

  class SearchScope
    attr_accessor :name, :model, :reflection

    def initialize(name, model)
      self.model = model
      self.reflection = Reflection.new
    end

    def attributes(*args)
      args.each do |arg|
        attributes_hash arg.is_a?(Hash) ? arg : { arg => arg }
      end
    end

    def options(key, options = {})
      reflection.options[key.to_s] = (reflection.options[key.to_s] || {}).merge(options)
    end

    def aliases(hash)
      hash.each do |key, value|
        reflection.aliases[key.to_s] = value.is_a?(Class) ? value : value.to_s
      end
    end

    def scope(&block)
      reflection.scope = block
    end

    def sanitize(hash)
      hash.each do |key, value|
        reflection.sanitize[key.to_s] = value.is_a?(Class) ? value : value.to_s
      end
    end

    private

    def attributes_hash(hash)
      hash.each do |key, value|
        reflection.attributes[key.to_s] = Array(value).collect do |column|
          table, attribute = column.to_s =~ /\./ ? column.to_s.split(".") : [model.name.tableize, column]

          "#{table}.#{attribute}"
        end
      end
    end
  end
end
