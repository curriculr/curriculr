module Teach::AssessmentsHelper  
  def assessment_redirect_path
    if @lecture
      teach_course_unit_lecture_path(@course, @lecture.unit, @lecture, :show => :assess)
    elsif @unit
      teach_course_unit_path(@course, @unit, :show => :assessments)
    else
      teach_course_path(@course, :show => :assessments)
    end
  end
  
  def link_to_add_q_selectors(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    new_object.unit_id = @unit.id if @unit
    new_object.lecture_id = @lecture.id if @lecture
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      content_tag :div, :class => 'removable' do
        html = render("fields_4_q_selector", f: builder)
        html << '<hr>'.html_safe
      end
    end
    
    link_to(name, '#', class: "add_fields ui positive button", 
      data: {id: id, fields: fields.gsub("\n", "")})
  end
end
