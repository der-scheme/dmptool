module ApplicationHelper

  #to enable column sorting with toggle effects
  #current asc and current desc classes are for supporting an eventual arrow image
  #or css class (not yet implemented) associated with the sorting direction



  def sortable(column, title = nil, model: @model)
    fail ArgumentError, 'expected model to be of type ActiveRecord::Base' if
      model && !model.respond_to?(:human_attribute_name)

    title ||= model.human_attribute_name(column) if model
    title ||= t(".#{column}", default: column.titleize)

    css_class = column == params[:order_scope] ? "current #{params[:direction]}" : nil
    direction = column == params[:order_scope] && params[:direction] == "asc" ? "desc" : "asc"
    link_to title,
      {:order_scope => column, :direction => direction, :scope => @scope, :all_scope => @all_scope},
      {:class => css_class}
  end

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

  def set_page_history
    if session[:page_history].blank?
      session[:page_history] = []
    end
    if session[:page_history].length > 4
      session[:page_history].pop
    end
    session[:page_history].insert(0, request.path)
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
  # Proxies #render_back_button, overwrites the translation parameter with
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
                       href: params.merge(url_options).merge(s: s, e: e),
                       **options
  end

  def translate_enum(model, attribute, value)
    model_scope = case model
      when Symbol then model
      else
        if model.respond_to?(:to_model)
          model.to_model.class.model_name.singular.i18n_key
        else
          model.to_s.to_sym
        end
    end

    translate(value, scope: [:enum, model_scope, attribute])
  end
  alias_method :t_enum, :translate_enum
end
