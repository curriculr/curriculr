module WithSettings
  extend ActiveSupport::Concern

  included do
  end

  def get_setting_value(value, type)
  	return nil if value.nil?
  	case type
  	when 'boolean'
  		value.to_bool
  	when 'numeric'
  		value.to_f
  	when 'array'
  		value.split(',').map do |e| e.strip end
  	else
      if value.to_i.to_s == value || value.to_f.to_s == value
        value.to_f
      elsif value.to_bool.to_s == value
        value.to_bool
      else
  		  value
      end
  	end
  end

	def do_configure(config, redis_key = nil, return_url = nil)
    s = config
    keys = params[:setting].split(':')
    if request.post?
      if params[:key] && params[:value]
        case params[:op]
        when 'add', 'edit'
          keys.each do |k| s = s[k] end
          s[params[:key]] = get_setting_value(params[:value], params[:type])
          $redis.set redis_key, config.to_json unless redis_key.nil? || s[params[:key]].nil?
        end
      end
    elsif request.delete?
      keys.each do |k|
        if k == keys.last
          s.delete(k)
        else
          s = s[k]
        end
      end

      $redis.set redis_key, config.to_json if redis_key
    end

    redirect_to return_url if return_url
  end
end
