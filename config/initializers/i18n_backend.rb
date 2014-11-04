# Be sure to restart your server when you modify this file.
require "translator"

I18n.backend = I18n::Backend::Chain.new(Translator::Backend.new, I18n.backend)