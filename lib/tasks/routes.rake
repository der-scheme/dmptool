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

end
