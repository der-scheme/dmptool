
# Provides a monkey patch to a bug in Rails. Automatic scoping for translations
# is broken for non-HTML views, including the full filename. For instance, a
# translation ".foo" in the file app/views/something/else.js.erb will expand to
# "en.something.else.js.erb.foo", instead of "en.something.else.foo".
#
# Unfortunately, even if newer versions of Rails contained a bugfix, updating
# cannot be done without breaking dependent gems which, at the time of this
# writing, didn't provide a working version.
#
# Other workarounds would be to maintain two translations simultaneously
# (with and without the ".js.erb" in their scope), or to not use auto-scoping,
# which is not that simple either (as the translations that initially triggered
# this bug are called from helpers which can be called from more than one
# partial, therefore forcing one translation for all partials involved).

module ActionView
  module Helpers
    module TranslationHelper

      private
        def scope_key_by_partial(key)
          if key.to_s.first == "."
            if @virtual_path
              @virtual_path.gsub!(/\.js\.erb\Z/, '')  # This is the line in question.
              @virtual_path.gsub(%r{/_?}, ".") + key.to_s
            else
              raise "Cannot use t(#{key.inspect}) shortcut because path is not available"
            end
          else
            key
          end
        end

    end
  end
end
