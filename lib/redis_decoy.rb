class RedisDecoy
  def initialize(options)
    @db = {}
    @ready = false
  end 

  def get_ready
    config = YAML.load_file("#{Rails.root}/config/config-site.yml")
    @db['config.site'] = config['site'].to_json

    config = YAML.load_file("#{Rails.root}/config/config-account.yml")
    accounts = Account.all
    accounts.each do |a|
      @db["config.account.a#{a.id}"] = config['account'].to_json
    end
  
    config = YAML.load_file("#{Rails.root}/config/config-course.yml")
    courses = Course.unscoped.all
    courses.each do |c|
      @db["config.course.a#{c.account_id}_c#{c.id}"] = config['course'].to_json
    end

    @ready = true
  end 

  def set(key, value)
    @db[key] = value
  end

  def get(key)
    unless @ready
      get_ready 
    end

    @db[key]
  end

  def exists(key)
    @db.include?(key)
  end

  def del(key)
    @db.delete(key)
  end
end