module Teach::QuestionsHelper  
  def link_to_add_options(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      content_tag :div, :class => 'removable' do
        html = '<hr>'.html_safe
        html << render("fields_4_question", f: builder)
      end
    end
    
    link_to(name, '#', class: "add_fields #{css(button: :success, align: :right)}", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
