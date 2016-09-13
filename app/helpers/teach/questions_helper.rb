module Teach::QuestionsHelper  
  def link_to_add_options(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      content_tag :div, :class => 'removable' do
        render("fields_4_question", f: builder)
      end
    end
    
    link_to(name, '#', class: "add_fields ui primary button", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def question_kinds(survey = false)
    if survey
      t('config.question.kind').select{|k,v| Option.render_options[k][:survey]}
    else
      t('config.question.kind')
    end
  end
end
