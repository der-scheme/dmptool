OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

Rails.application.config.prompt_external_signup.map!{|provider| [provider, provider.to_s]}.flatten!
