# Temporary fix: needed to add the aliases that redis-rb 4.0 removed.
class Redis 
  alias :[] :get
  alias :[]= :set
end

module Translator
  def self.store
    if Rails.application.secrets.redis_enabled
      @store ||= Redis.new(db: Rails.application.config.redis_databases[Rails.env.to_s])
    else
      @store ||= {}
    end
  end

  class Backend < I18n::Backend::KeyValue
    include I18n::Backend::Memoize

    def initialize
      super(Translator.store)
    end
  end

  def self.from_yaml(locale, output, data, key)
    data.each do |k, t|
      if t.kind_of? Hash
        from_yaml(locale, output, t, "#{key}.#{k}")
      else
        output["#{key}.#{k}"[(locale.length + 2)..-1]] = t
      end
    end
  end

  def self.to_yaml(locale, keys)
    keys = Rails.application.secrets.redis_enabled ? Translator.store.keys("#{locale}.#{keys}") : []
    data = {}
    c = nil

    if keys.present?
      keys.uniq.compact.sort.each do |k|
        if k.last != '.'
          c = data
          parts = k.split('.')

          parts.each_with_index do |p, i|
            if i == parts.count - 1
              c[p] = ActiveSupport::JSON.decode(Translator.store.get(k))
            else
              c[p] = {} if c[p].blank?
              c = c[p]
            end
          end
        end
      end
    end

    data.to_yaml
  end

  def self.translations(locale, keys)
    keys = Rails.application.secrets.redis_enabled ? Translator.store.keys("#{locale}.#{keys}") : []
    data = {}
    c = nil

    if keys.present?
      keys.uniq.compact.sort.each do |k|
        if k.last != '.'
          c = data
          parts = k.split('.')

          parts.each_with_index do |p, i|
            if i == parts.count - 1
              c[p] = ActiveSupport::JSON.decode(Translator.store.get(k))
            else
              c[p] = {} if c[p].blank?
              c = c[p]
            end
          end
        end
      end
    end

    data
  end

  def self.to_hash(locale, keys)
    keys = Rails.application.secrets.redis_enabled ? Translator.store.keys("#{locale}.#{keys}") : []
    data = {}

    if keys.present?
      keys.uniq.compact.sort.each do |k|
        if k.last != '.'
          parts = k.split('.')
          data[parts.last] = ActiveSupport::JSON.decode(Translator.store.get(k))
        end
      end
    end

    data
  end
end
