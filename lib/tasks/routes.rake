namespace :routes do
  desc 'Print out all defined routes pointing to nonexistent actions'
  task broken: :environment do
    begin
      Rails.application.eager_load!
    rescue OpenSSL::SSL::SSLError
    end
    controllers = Hash[ApplicationController.descendants.map {|controller| [controller.controller_name, controller]}]

    routes = Rails.application.routes.routes
        .select {|route| route.defaults.key?(:controller)}
        .reject do |route|
      controller_class = controllers[route.defaults[:controller]]
      controller_class.instance_methods.include?(route.defaults[:action].to_sym) if controller_class
    end

    require 'action_dispatch/routing/inspector'
    inspector = ActionDispatch::Routing::RoutesInspector.new(routes)
    puts inspector.format(ActionDispatch::Routing::ConsoleFormatter.new, ENV['CONTROLLER'])
  end

end
