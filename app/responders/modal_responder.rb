module Responders::ModalResponder 
  def to_js
    default_render
  rescue ActionView::MissingTemplate => error
    if get?
      raise error
    elsif has_errors? && default_action
      render :action => default_action
    else
      render 'reload'
    end
  end
end
  