namespace :routes do
  desc 'Print out all defined routes pointing to nonexistent or problematic actions'
  task broken: :environment do
    begin
      Rails.application.eager_load!
    rescue OpenSSL::SSL::SSLError
    end
    # Hash with all controllers for fast lookup
    controllers = Hash[ActionController::Base.descendants.map {|controller| [controller.controller_path, controller]}]

    routes = Rails.application.routes.routes
        .select {|route| route.defaults.key?(:controller)}
        .reject do |route|
      controller_class = controllers[route.defaults[:controller]]
      # Consider a route intact if:
      # 1. the controller exists
      # 2. the action exists
      # 3. the action method is public
      controller_class.public_instance_methods.include?(route.defaults[:action].to_sym) if controller_class
    end

    require 'action_dispatch/routing/inspector'
    inspector = ActionDispatch::Routing::RoutesInspector.new(routes)
    # Don't print anything if there are no routes to display (— would print
    # an informative messages about routes, that wouldn't make sense in this
    # context, otherwise)
    formatter = ActionDispatch::Routing::ConsoleFormatter.new
    formatter.define_singleton_method(:no_routes) {}
    result = inspector.format(formatter, ENV['CONTROLLER'])

    puts result if result.present?
  end

  desc 'Print out all defined routes that are potentially vulnerable to CSRF/XSS'
  task dangerous: :environment do
    # We assume that everything with names containing tokens like
    # add/remove/delete or actions like create does change stuff on the server.
    # Such functionality should not be reachable using GET, as it introduces
    # potential vulnerabilities to CSRF/XSS.

    routes = Rails.application.routes.routes
        .reject {|route| route.defaults[:format] == :json}
        .select {|route| route.constraints[:request_method] =~ 'GET'}
        .select do |route|
      route.name =~ /add[^a-zA-Z]|remove|delete/ ||
          route.defaults[:action].in?('create', 'update')
    end

    require 'action_dispatch/routing/inspector'
    inspector = ActionDispatch::Routing::RoutesInspector.new(routes)
    # Don't print anything if there are no routes to display (— would print
    # an informative messages about routes, that wouldn't make sense in this
    # context, otherwise)
    formatter = ActionDispatch::Routing::ConsoleFormatter.new
    formatter.define_singleton_method(:no_routes) {}
    result = inspector.format(formatter, ENV['CONTROLLER'])

    puts result if result.present?
  end

end
