Rails.application.routes.draw do
  # Concerns
  concern :sortable do
    post :sort, :on => :collection
  end

  concern :with_media do
    resources :media do
      get :multi, :on => :new, :as => :multi
    end
  end

  concerns :with_media

  concern :with_materials do
    resources :materials, :only => [:show, :new, :create, :destroy]
  end

  concern :with_pages do
    resources :pages, :except => [:index]
  end

  concern :assessable do
    resources :questions, :except => :show do
      post :sort_option, :on => :member
      post :include_in_lecture, :on => :member
    end

    resources :assessments, :except => :index do
      resources :q_selectors, :except => [:show, :index]
      get :preview, :on => :member
      post :sort_q_selector, :on => :member
    end
  end

  concern :announceable do
    resources :updates, :except => [:show]
  end

  resources :users do
    resources :access_tokens, :only => [:create, :destroy], :module => 'admin' do
      get :revoke, :on => :member
    end

    put :confirm, :on => :member
  end

  resources :pages
  get 'blogs', :to => 'pages#blogs', :as => 'blogs'
  get 'pages/localized/:slug', :to => 'pages#localized', :as => 'localized_page'

	# Courses Resources
  namespace :teach do
  	resources :courses, concerns: [:with_media, :with_materials, :assessable, :with_pages] do
      #resources :settings, :only => [:index, :update]
	    resources :instructors, :except => [:show, :index], concerns: [ :sortable ]
  	  resources :units, concerns: [:sortable, :with_materials, :assessable, :with_pages] do
  	    resources :lectures, :except => :index, concerns: [:sortable, :with_materials, :assessable, :with_pages] do
          put :discuss, :on => :member
          post :content_sort, :on => :member
        end

        resources :updates, :except => [:index, :show]
      end

      resources :klasses do
        resources :forums, :except => :show

        resources :updates, :except => [:index, :show] do
          put :make, :on => :member
        end

        get :invite, :on => :member
        post :invite, :on => :member
        put :approve, :on => :member
        put :ready, :on => :member
        put :discuss, :on => :member
      end

      resources :forums, :except => :show # For common forums
      resources :updates, :except => [:index, :show] do
        put :make, :on => :member
      end

      get :settings, :on => :member
      post :configure, :on => :member
      delete :configure, :on => :member

      get 'dashboard/courses/:course_id', :to => 'dashboard#show', :as => 'dashboard'
    end
  end

  # Klasses Resources
  namespace :learn do
    resources :students

    resources :klasses, :only => [:index, :show] do
      resources :lectures, :only => [:index, :show] do
        member do
          get :assessments, :as => :show_assessments_of, :to => 'lectures#show_assessments'
          get :comments, :as => :show_comments_of, :to => 'lectures#show_comments'
          get 'materials/:material_id', :as => :show_material_of, :to => 'lectures#show_material'
          get 'pages/:page_id', :as => :show_page_of, :to => 'lectures#show_page'
          get 'questions/:question_id', :as => :show_question_of, :to => 'lectures#show_question'
          post 'questions/:question_id', :as => :attempt_question_of, :to => 'lectures#show_question'
          get 'assessments/:assessment_id', :as => :show_assessment_of, :to => 'lectures#show_assessment'
        end
      end

      resources :units, :only => [] do
        resources :pages, :only => :index
        resources :materials, :only => :index
      end

      resources :pages, :only => [ :show, :index ]
      resources :materials, :only => [ :show, :index ]
      resources :updates, :except => [ :show, :index ]
      get :access, :on => :member
      get :report, :on => :member
      get :students, :on => :member

      resources :forums do
        resources :topics, :except => :index do
          resources :posts, :except => [:index, :show] do
            resources :posts

            put :up, :on => :member
            put :down, :on => :member
          end

          put :up, :on => :member
          put :down, :on => :member
        end
      end

      resources :assessments, :only => [:index, :show] do
        resources :attempts, :only => [:new, :create] do
          post :show_answer, :on => :member
        end

        post 'questions/:question_id/show_answer',
          :to => 'attempts#show_answer',
          :as => 'show_answer'
      end

      put 'accept', :to => 'klasses#accept', :on => :member
      put 'decline', :to => 'klasses#decline', :on => :member

    	put 'drop', :to => 'klasses#drop', :on => :member
      get 'enroll', :to => 'klasses#enroll', :on => :member
      post 'enroll', :to => 'klasses#enroll', :on => :member
      put 'students/:id/current', :to => 'students#current',
        :as => 'current_student'
      get 'students/:student_id/report', :to => 'klasses#report', :as => 'student_report'

      get 'dashboard/klasses/:klass_id', :to => 'dashboard#show', :as => 'dashboard'
    end

    get 'search/klasses', :to => 'klasses#search', :as => 'klass_search'
  end

  # Mountable engines
  Rails.application.config.site_engines.each do |name, engine|
    mount engine[:class] => "/#{name}"
  end

  namespace :admin do
    resources :announcements, :except => :show do
      get :hide, :on => :member
    end

    resources :accounts do
      get :settings, :on => :member
      post :configure, :on => :member
    end

    resources :users, :only => [:new, :create]

    get 'dashboard', :to => 'dashboard#show', :as => 'dashboard'
  end

  get 'admin/config/edit', :to => 'admin/config#edit'
  post 'admin/config', :to => 'admin/config#update'

  get 'admin/translation/:locale/edit', :to => 'admin/translations#edit', :as => :edit_admin_translation
  post 'admin/translation/:locale', :to => 'admin/translations#update', :as => :admin_translation
  delete 'admin/translation/:locale', :to => 'admin/translations#update'

  post "miscellaneous/contactus"

  # Top-level pages
  get 'about', :to => "miscellaneous#team", :as => 'about'
  get 'contactus', :to => "miscellaneous#contactus", :as => 'contactus'
  get 'play/:id', :to => "media#play", :as => 'play'
  get 'home', :to => 'users#home', :as => :home

  namespace :auth do
    resources :registrations
    resources :sessions
    resources :password_resets
    
    get 'signup', to: 'registrations#new'
    get ':token/confirm', to: 'registrations#confirm', as: :confirm_email
    get ':token/reconfirm', to: 'registrations#reconfirm', as: :reconfirm_email
    get 'signin', to: 'sessions#new'
    get ':provider/callback', to: 'sessions#create'
    get 'signout', to: 'sessions#destroy'
  end

  root :to => 'users#front', :via => :get

  # Handling errors
  match '/401', to: 'errors#unauthorized', via: :all, as: :error_401
  match '/404', to: 'errors#not_found', via: :all, as: :error_404
  match '/422', to: 'errors#unprocessable', via: :all, as: :error_422
  match '/500', to: 'errors#server_error', via: :all, as: :error_500

  #get "*any", via: :all, to: "errors#not_found"
end
