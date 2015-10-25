module Admin
  class TranslationsController < ApplicationController
    include WithSettings
    before_action :require_admin

    def create
    end

    def edit
      @locale = params[:locale]
      if params[:translation] && params[:translation][:locale]
        @locale = params[:translation][:locale]
      end

      @translations = Translator.translations(@locale, current_user.id == 1 ? "*" : "#{current_account.slug}.site.*")
      render 'admin/translations/show'
    end

    def update
      if params[:locale] && params[:setting]
        @locale  = params[:locale]
        if request.post?
          t = {}
          c = t
          keys = params[:setting].split(':')
          keys.take(keys.count).each do |k|
            c[k] = {}
            c = c[k]
          end

          do_configure(t)

          translation = {}
          Translator.from_yaml(@locale, translation, t, '')
          if translation.first.second.present?
            I18n.backend.store_translations( @locale, translation, :escape => false )
          end
        elsif request.delete?
          Translator.store.del(params[:setting].gsub(':', '.'))
        end

        redirect_to edit_admin_translation_path(@locale)
      end
    end
  end
end
