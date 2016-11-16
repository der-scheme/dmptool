Rails.configuration.ldap_options = YAML.load_file(Rails.root.join("config","ldap.yml"))[Rails.env]

Rails.application.config.middleware.use OmniAuth::Strategies::LDAP,
    :title => Rails.configuration.ldap_options['omniauth_title'],
    :host => Rails.configuration.ldap_options['host'],
    :port => Rails.configuration.ldap_options['port'],
    :method => Rails.configuration.ldap_options['omniauth_method'],
    :base => Rails.configuration.ldap_options['user_base'],
    :uid => Rails.configuration.ldap_options['omniauth_uid'],
    :bind_dn => Rails.configuration.ldap_options['admin_user'],
    :password => Rails.configuration.ldap_options['admin_password'],
    :allow_anonymous => false