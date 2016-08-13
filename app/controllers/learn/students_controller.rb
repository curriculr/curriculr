module Learn
  class StudentsController < BaseController
    before_action :set_student, only: [:edit, :update, :destroy, :current]
    responders :flash, :http_cache
    
    def index
      @students = current_user.students.where("relationship <> 'self'")
    end

    def new
      @student = current_user.students.new
    end

    def create
      @student = Student.new(student_params)
      respond_with @student do |format|
        if @student.save
          format.html { redirect_to learn_students_path }
        else
          format.html { render 'new' }
        end
      end
    end
  
    def edit
    end
  
    def update
      respond_with @student do |format|
        if @student.update(student_params)
          format.html { redirect_to learn_students_path }
        else
          format.html { render 'edit' }
        end
      end
    end
    
    def destroy
      @student.destroy
      respond_with @student do |format|
        format.html { redirect_to learn_students_path }
      end
    end

    def current
      @current_student = nil if @current_student && @student && @student.id != @current_student.id
      session[:current_student] = @student.id
      redirect_to learn_klass_path(@klass)
    end
    
    private 
      def set_student
        @student = Student.find(params[:id])
      end
      
      def student_params
        params.require(:student).permit(:user_id, :name, :relationship, :avatar)
      end
  end
end