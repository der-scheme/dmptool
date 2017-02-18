
Rails.root.join('config', 'shibboleth.yml').tap do |conf_file|
  next unless File.exists?(conf_file)

  Rails.application.config.middleware.use OmniAuth::Builder do
    opts = YAML.load_file(conf_file)[Rails.env]
    provider :shibboleth, opts.symbolize_keys
    Dmptool2::Application.shibboleth_host = opts['host']
  end
end
