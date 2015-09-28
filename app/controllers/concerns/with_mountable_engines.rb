module WithMountableEngines
  extend ActiveSupport::Concern

  included do
    helper_method :mounted?, :mountable_fragments
  end

  def mounted?(engine)
    Rails.application.config.site_engines[engine.to_sym].present?
  end

  def mountable_fragments(hook, options={})
    if (ndx = (hook_str = hook.to_s).rindex(/\_/))
      html = ''
      fragment = hook_str[(ndx + 1)..hook_str.length].to_sym
      options[fragment] = hook_str[0..(ndx - 1)].to_sym
      Rails.application.config.site_engines.each do |name, engine|
        # puts "======"
        # puts "#{engine[:fragments]} #{engine.stringify_keys['fragments']}"
        if engine[:fragments] && engine[:fragments][fragment]
          # puts "{\n\n\n#{name}/fragments/#{fragment}\n\n\n#{options}}"
          html << render_to_string(partial: "#{name}/fragments/#{fragment}", locals: options)
        end
      end

      html.html_safe
    end

    # puts "\n\n\n#{ndx}\n\n\n#{hook_str}\n\n\n#{fragment}\n\n\n#{options[fragment]}"
  end
end
