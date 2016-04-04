{
  header: {
    navigation: [
      {href: {controller: :static_pages, action: :home}},
      {href: {controller: :dashboard, action: :show}, if: :current_user},
      {href: {controller: :static_pages, action: :guidance}},
      {href: {controller: :plans, action: :public}},
      {href: {controller: :static_pages, action: :help}},
      {href: {controller: :static_pages, action: :contact}},
      {
        href: {controller: :static_pages, action: :about},
        children: [
          {
            href: 'http://dmptool.askbot.com',
            label: {
              key: 'layouts.header.faq_link',
              fallback: 'FAQ'
            }
          },
          {href: {controller: :static_pages, action: :partners}}
        ]
      }
    ]
  },
  footer: {
    credits: lambda do
            "#{I18n.t("layouts.footer.copyright_text")}".html_safe
      end,
    links: [
      {href: {controller: :static_pages, action: :privacy}},
      {href: {controller: :static_pages, action: :terms_of_use}},
      {href: {controller: :static_pages, action: :contact}},
      {href: {controller: :static_pages, action: :about}},
    ],
    icons: [
    ]
  }
}
