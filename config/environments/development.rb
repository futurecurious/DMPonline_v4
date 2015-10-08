DMPonline4::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Use syslog for logging
  config.logger = Logger::Syslog.new('DMPonline_v4')
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  #devise config
  config.action_mailer.default_url_options = { :host => 'houston.library.ualberta.ca' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 25 }
  
  ActionMailer::Base.default :from => 'data@ualberta.ca'
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = { :address => "localhost", :port => 25 }
  
  
	# Add the fonts path
	config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
	
	# Precompile additional assets
	config.assets.precompile += %w( .svg .eot .woff .ttf )

	# Error notifications by email
	 config.middleware.use ExceptionNotification::Rack,
	  :email => {
	    :email_prefix => "[DMP Builder ERROR] ",
	    :sender_address => %{"No-reply" <noreply@library.ualberta.ca>},
	    :exception_recipients => %w{dittest@ualberta.ca}
	  }
	  
	
config.action_mailer.perform_deliveries = true
#config.action_mailer.raise_delivery_errors = true

BetterErrors::Middleware.allow_ip! '192.168.0.1/16'
	  
end
