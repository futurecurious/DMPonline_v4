class ApplicationController < ActionController::Base
protect_from_forgery
# Added settings for locales
 before_filter :set_locale

 def set_locale
   I18n.locale = params[:locale] || I18n.default_locale
 end 

 def self.default_url_options(options={})
   options.merge({ :locale => I18n.locale })
 end
# Added setting for passing local params accross pages
 def default_url_options(options = {})
   {locale: I18n.locale }.merge options
 end
  
 # Override build_footer method in ActiveAdmin::Views::Pages
  require 'active_admin_views_pages_base.rb'
  
 rescue_from CanCan::AccessDenied do |exception|
     redirect_to locale_root_path, :alert => exception.message
 end
 
 	after_filter :store_location

	def store_location
	 # store last url - this is needed for post-login redirect to whatever the user last visited.
		if (request.fullpath != "/users/sign_in" && \
			request.fullpath != "/users/sign_up" && \
			request.fullpath != "/users/password" && \
            request.fullpath != "/users/sign_up?nosplash=true" && \
			!request.xhr?) # don't store ajax calls
		  session[:previous_url] = request.fullpath 
   		end
	end

	def after_sign_in_path_for(resource)
	  session[:previous_url] || locale_root_path
	end

	def after_sign_up_path_for(resource)
	  session[:previous_url] || locale_root_path
	end
	
	def after_sign_in_error_path_for(resource)
	  session[:previous_url] || locale_root_path
	end
	
	def after_sign_up_error_path_for(resource)
	  session[:previous_url] || locale_root_path
	end
	
	def authenticate_admin!
		redirect_to locale_root_path unless user_signed_in? && current_user.is_admin?
	end

	def get_plan_list_columns
		if user_signed_in?
			@selected_columns = current_user.settings(:plan_list).columns
			@all_columns = Settings::PlanList::ALL_COLUMNS
		end
	end

end
