module ApplicationHelper
  include Sortable::Helper

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', :class => "add_fields btn", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def fix_url(u)
    begin
      uri = URI.parse(u)
      uri.kind_of?(URI::HTTP)
      if uri.scheme.nil?
        return "http://#{u}"
      end
      return u
    rescue URI::InvalidURIError
      return "http://#{u}"
    end
  end


  def bootstrap_class_for flash_type
    case flash_type
    when :success
    "alert-success"
    when :error
    "alert-error"
    when :alert
    "alert-block"
    when :notice
    "alert-info"
    else
    flash_type.to_s
    end
  end

  def menu_level(x)
    return '' unless @display_menu
    m = @display_menu.split(':')
    return '' if x >= m.length
    m[x]
  end

  def response_value_s(response)
    if response.nil? then
      return "[No response]"
    elsif !response.numeric_value.nil? then
      return response.numeric_value.to_s
    elsif !response.date_value.nil? then
      return response.date_value.to_s
    elsif !response.text_value.nil?
      return response.text_value.html_safe
    end
  end

  def current_page_includes?(*args)
    args.each do |a|
      return true if current_page?(a)
    end
    return false
  end

  #returns the origin url, but only if it isn't set already in params
  def smart_origin_url
    if params[:origin_url].blank?
      request.original_url
    else
      params[:origin_url]
    end
  end

  #returns true or false for customization section
  def customization_section?
    current_page_includes?(edit_resource_context_path(@resource_context),
                           new_resource_context_path,
                           customization_requirement_path(@resource_context)) ||
        ( params[:controller] == 'customizations' && params[:requirement_id] &&
            current_page?(customization_requirement_path(@resource_context, requirement_id: params[:requirement_id])))
  end

  def require_admin
    unless user_role_in?(:dmp_admin)
      flash[:error] = "You must be an administrator to access this page."
      session[:return_to] = request.original_url
      redirect_to choose_institution_path and return
    end
  end

  def translate_visibility(visibility)
    t("globals.enums.visibility.#{visibility}")
  end

  def display_detail_overview
    t('globals.template.details.overview')
  end

  def display_detail_details
    t('globals.template.details.details')
  end

  def display_detail_customize
    t('globals.template.details.action_customize')
  end

  def display_detail_delete
    t('globals.template.details.action_delete')
  end

  def render_submit_button(cntnt = nil, trnslt = nil,
                           t: nil, translate: nil,
                           content: nil, text: nil,
                           **options)
    t ||= translate || trnslt
    content ||= text || cntnt

    render partial: 'shared/submit_button', object: t,
           locals: {tid: t, content: content, attributes: options}
  end

  ##
  # Proxies #render_submit_button and overwrites the translation parameter with
  # <code>'.save'</code>.

  def render_save_button(*args, t: nil, translate: nil, **options)
    render_submit_button(*args, t: '.save', **options)
  end

  ##
  # Proxies #render_submit_button and overwrites the translation parameter with
  # <code>'.save_changes'</code>.

  def render_save_changes_button(*args, t: nil, translate: nil, **options)
    render_submit_button(*args, t: '.save_changes', **options)
  end

  def render_button(cntnt = nil, trnslt = nil,
                           t: nil, translate: nil,
                           content: nil, text: nil,
                           **options)
    t ||= translate || trnslt
    content ||= text || cntnt

    options[:class] ||= ''
    options[:class].concat(' btn')

    render partial: 'shared/button',
           locals: {tid: t, content: content, attributes: options}
  end

  ##
  # Proxies #render_button and overwrites the translation parameter with
  # <code>'.cancel'</code>.

  def render_cancel_button(*args, t: nil, translate: nil, **options)
    render_button(*args, t: '.cancel', type: :reset, **options)
  end

  def render_button_link(cntnt = nil, lnk = nil,
                         t: nil, translate: nil,
                         tparams: {},
                         content: nil, text: nil,
                         link: nil, href: nil, url: nil,
                         green: false,
                         **options)

    t ||= translate
    content ||= text || cntnt
    link ||= href || url || lnk

    options[:class] ||= ''
    options[:class].concat(' btn-green') if green

    render partial: 'shared/button_link',
           locals: {tid: t, content: content, href: link, tparams: tparams, attributes: options}
  end

  ##
  # Proxies #render_button_link, overwrites the translation parameter with
  # <code>'.back'</code> (or <code>'.arrow_back'</code> if
  # <code>arrow: true</code>) and links to <code>:back</code>, unless otherwise
  # specified.

  def render_back_button(lnk = nil,
                         arrow: false, green: true,
                         link: nil, href: nil, url: nil,
                         **options)
    t = arrow ? '.arrow_back' : '.back'
    link ||= href || url || lnk || :back

    render_button_link(t: t, href: link, green: green, **options)
  end

  def render_filter_button(url_options = {}, s: 'a', e: 'z', **options)
    options[:class] ||= ''
    options[:class].concat(" view#{s.upcase}-#{e.upcase}")

    render_button_link t: '.filter', tparams: {s: s, e: e},
                       href: filter_params.merge(url_options).merge(s: s, e: e),
                       **options
  end

  ## Renders a remove link.

  def render_remove_link(cntnt = nil, lnk = '#',
                         t: :remove, translate: nil, content: nil, text: nil,
                         link: nil, href: nil, url: nil, **options)

    translate ||= t
    content ||= text || cntnt || t("helpers.render.link.#{translate}")
    link ||= href || url || lnk

    options[:class] ||= ''
    options[:class].concat(' red remove_fields')

    link_to content_tag(:span, '', class: 'icon remove') + content,
            '#', **options
  end

  ##
  # Return a human readable translation for the given enum (or boolean)
  # attribute value.
  #
  # The +value+ parameter can be omitted with the following semantics.
  # 1. If +model+ is an instance of ActiveRecord::Base, the value of the
  #    +attribute+ will be used.
  # 2. Otherwise, a deduction of the actual model class and lookup of its
  #    corresponding attribute is attempted. If the contents of the +limit+
  #    parameter is an array, its first entry is chosen.
  # 3. The fallback value is always +false+.

  def translate_enum(model, attribute, value = nil)
    case model
    when Symbol
      model_scope = model
      model_class = model.to_s.classify.constantize
    when Class
      model_scope = model.model_name.i18n_key
      model_class = model
    when ActiveRecord::Base
      model_class = model.class
      model_scope = model_class.model_name.i18n_key
    else
      model = model.to_s
      model_scope = model.to_sym
      model_class = model.classify.constantize
    end

    value = model.try(:attributes)
        .try(:[], attribute.to_s)     unless value || value == false
    value = model_class.columns_hash[attribute.to_s]
        .limit.try(:first) || false   unless value || value == false

    value = value.to_s.to_sym unless value.is_a? Symbol

    translate(value, scope: [:enum, model_scope, attribute])
  end
  alias_method :t_enum, :translate_enum

  def options_for_enum_select(args = nil, selectd = nil, model: nil, attribute: nil, **options)
    unless args.is_a? Array
      selectd = args
      args = nil
    end

    selected ||= selectd
    if selected.is_a? ActiveRecord::Base
      model ||= selected.class
      selected = selected.try(attribute)
    end

    model ||= controller_name.classify.constantize
    args  ||= model.columns_hash[attribute.to_s].limit

    options_for_select(args.map {|arg| [t_enum(model, attribute, arg), arg]},
                       **options.merge(selected: selected))
  end

  def i18n_include_tag(*scopes)
    scopes = [
      'date.formats', 'time.formats', 'datetime.formats',
      'globals.messages.prompt', '.', 'js.application'
    ] if scopes.empty?

    translations = {}
    scopes.map!(&:to_s).each do |scope|
      result = I18n.t(scope_key_by_partial(scope), default: {})
      if scope.first == '.'
        result.merge!(I18n.t("js.#{controller_name}#{scope}", default: {}))
      end

      scope.gsub!(/\.\z/, '')
      result.each do |key, value|
          next unless value.is_a?(String)

          translations["#{scope}.#{key}"] = value
        end
    end

    javascript_tag <<EOF
      I18n = (typeof x === 'undefined') ? {} : I18n;
      {
        var translations = #{translations.to_json.html_safe};
        for (var key in translations) { I18n[key] = translations[key]; }
      }
EOF
  end

  ##
  # Return the #params, purged from those we don't want in there (like the
  # ones inserted by ajax calls).

  def filter_params
    params.reject {|k, v| k == 'authenticity_token' || k == '_method'}
  end
end
