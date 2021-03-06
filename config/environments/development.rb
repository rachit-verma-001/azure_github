Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.force_ssl = true

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  config.action_mailer.default_url_options = { host: 'localhost', port: 4000 }
  # config.action_mailer.delivery_method = :letter_opener

  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true

  # config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :smtp

  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => "rachitverma.001@gmail.com",
    :password             => "gmail0028871338693",
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

  # config.hosts << "cb44-182-77-7-232.ngrok.io"
  # config.hosts << "4149-20-124-179-137.ngrok.io"

  # config.hosts << "azure-test-vm-window.eastus.cloudapp.azure.com"




  config.hosts << "66c6-182-77-10-73.ngrok.io"

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
