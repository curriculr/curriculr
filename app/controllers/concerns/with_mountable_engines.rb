module WithMountableEngines
  extend ActiveSupport::Concern

  included do
    helper_method :mounted?, :mountable_fragments
  end

  def mounted?(engine)
    Rails.application.config.site_engines[engine.to_sym].present?
  end
  
  def mountable_fragments(hook, options={})
    html = ''
    Rails.application.config.site_engines.each do |name, engine|
      if engine[:fragments].present? and engine[:fragments][hook]
        html << render_to_string(partial: "#{name}/fragments/#{hook}", locals: options)
      end
    end
    
    html.html_safe
  end
end