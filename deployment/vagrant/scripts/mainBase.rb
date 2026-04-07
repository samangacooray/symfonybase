class MainBase
    attr_reader :home
    attr_reader :config
    attr_reader :defaults
    attr_reader :settings
    attr_reader :scripts
    attr_reader :deployFiles
      def initialize(homePath, configPath, defaults, settings, scripts, deployFiles)
        @home = homePath
        @config = configPath
        @defaults = configPath + "/" + defaults
        @settings = configPath + "/" + settings
        @scripts = configPath + "/" + scripts
        @deployFiles = configPath + "/" + deployFiles
      end
  end