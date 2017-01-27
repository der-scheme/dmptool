
require_dependency 'route_i18n'   # This seems to be autoloaded in production, but not in development mode.

Dmptool2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  # The deployment to the new AWS dev server fails unless bootstrap's glyphicons are precompiled
  # Not an issue in stage and prod where all assets are precompiled
  config.assets.precompile += ['glyphicons-halflings.png', 'glyphicons-halflings-white.png']
  config.assets.precompile += %w( scaffolds.css )
  config.assets.precompile += %w( orcid_widget.js )

  config.log_level = :debug

  #special settings if you want to configure Unicorn logs for development use of unicorn server
  if defined? Hulk
    Hulk::Application.configure do
      # ...
      # other config settings for development
      # ...

      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get('DEBUG')
      # ...
    end
  end

  # for email notifications when an exception occurs
  # !!!!! change exception_recipients accordingly !!!!
  Dmptool2::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Dmptool2 Exception] ",
      :sender_address => %{"notifier"},
      :exception_recipients => %w{exception_receiver1@localhost execption_receiver2@localhost}
    }

  config.action_mailer.delivery_method = :file
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.file_settings = { :location => Rails.root.join('tmp/mail') }

end
