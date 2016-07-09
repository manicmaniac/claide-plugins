require 'claide/command/plugins_helper'
require 'claide/command/gem_helper'

module CLAide
  class Command
    class Plugins
      # The list subcommand. Used to list all known plugins
      #
      class List < Plugins
        self.summary = 'List all known plugins'
        self.description = <<-DESC
                List all known plugins (according to the list
                hosted on github.com/CocoaPods/cocoapods-plugins)
        DESC

        def self.options
          super.reject { |option, _| option == '--silent' }
        end

        def run
          plugins = PluginsHelper.known_plugins
          GemHelper.download_and_cache_specs if self.verbose?

          name = CLAide::Plugins.config.name
          UI.title "Available #{name} Plugins:" do
            plugins.each do |plugin|
              PluginsHelper.print_plugin plugin, self.verbose?
            end
          end
        end
      end
    end
  end
end
