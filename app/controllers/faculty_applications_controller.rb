class FacultyApplicationsController < AuthorizedController
  before_action :set_faculty_application, only: [:show, :edit, :update, :destroy, :approve, :decline]
  respond_to :html
  responders :flash, :http_cache

  def index
    @faculty_applications = FacultyApplication.all
    respond_with(@faculty_applications)
  end

  def show
    respond_with(@faculty_application)
  end

  def new
    @faculty_application = FacultyApplication.new(
      :name => current_user.name,
      :about => current_user.profile.about,
      :prefix => current_user.profile.prefix)

    respond_with(@faculty_application)
  end

  def edit
  end

  def create
    @faculty_application = FacultyApplication.new(faculty_application_params)
    @faculty_application.user = current_user
    if @faculty_application.save
      respond_with(@faculty_application) do |format|
        format.html { redirect_to home_path}
      end
    else
      render :new
    end
  end

  def update
    if @faculty_application.update(faculty_application_params)
      respond_with(@faculty_application) do |format|
        format.html { redirect_to home_path}
      end
    else
      render :edit
    end
  end

  def approve
    success = false
    @faculty_application.transaction do
      @faculty_application.update(:approved => true)
      @faculty_application.user.add_role :faculty

      if @faculty_application.update_profile
        @faculty_application.user.profile.update(
          :about => @faculty_application.about,
          :prefix => @faculty_application.prefix)
      end

      success = true
    end

    if success
      Mailer.faculty_application(
        current_account.slug,
        current_account.config['mailer']['noreply'],
        current_user.email,
        url_for(:controller => 'devise/sessions', :action => 'new'),
        true
      ).deliver_later
    end

    respond_with(@faculty_application) do |format|
      format.html { redirect_to home_path}
    end
  end

  def decline
     if @faculty_application.update(:approved => false, :declined_at => Time.zone.now)
       Mailer.faculty_application(
         current_account.slug,
         current_account.config['mailer']['noreply'],
         current_user.email,
         url_for(:controller => 'devise/sessions', :action => 'new'),
         false
       ).deliver_later
     end

    # send Email
    respond_with(@faculty_application) do |format|
      format.html { redirect_to home_path}
    end
  end

  def destroy
    @faculty_application.destroy
    respond_with(@faculty_application)
  end

  private
    def set_faculty_application
      @faculty_application = FacultyApplication.find(params[:id])
    end

    def faculty_application_params
      params.require(:faculty_application).permit(:name, :about, :prefix, :update_profile,
        :course, :description, :weeks, :workload, :locale, :country)
    end
end
