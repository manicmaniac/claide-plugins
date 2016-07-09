require File.expand_path('../../../spec_helper', __FILE__)
require 'tmpdir'

# The CocoaPods namespace
#
module CLAide
  describe Command::Plugins::Create do
    extend SpecHelper::PluginsCreateCommand

    before do
      UI_OUT.reopen
    end

    it 'registers itself' do
      Command.parse(%w(plugins create)).
        should.be.instance_of Command::Plugins::Create
    end

    #--- Validation

    it 'should require a name is passed in' do
      @command = create_command
      should.raise(CLAide::Help) do
        @command.validate!
      end.message.should.match(/A name for the plugin is required./)
    end

    it 'should require a non-empty name is passed in' do
      @command = create_command('')
      should.raise(CLAide::Help) do
        @command.validate!
      end.message.should.match(/A name for the plugin is required./)
    end

    it 'should require the name does not have spaces' do
      @command = create_command('my gem')
      should.raise(CLAide::Help) do
        @command.validate!
      end.message.should.match(/The plugin name cannot contain spaces./)
    end

    #--- Naming

    it 'should prefix the given name if not already' do
      @command = create_command('unprefixed')
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @command.run
        end
      end
      UI_OUT.string.should.include('Creating `claide-unprefixed` plugin')
    end

    it 'should not prefix the name if already prefixed' do
      @command = create_command('claide-prefixed')
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @command.run
        end
      end
      UI_OUT.string.should.include('Creating `claide-prefixed` plugin')
    end

    #--- Template download

    it 'should download the default template repository' do
      @command = create_command('claide-banana')

      template_repo = 'https://github.com/CocoaPods/' \
        'cocoapods-plugin-template.git'
      git_command = ['clone', template_repo, 'claide-banana']
      @command.expects(:git!).with(git_command)
      @command.expects(:configure_template)
      @command.run
      UI_OUT.string.should.include('Creating `claide-banana` plugin')
    end

    it 'should download the passed in template repository' do
      alt_repo = 'https://github.com/CocoaPods/' \
        'claide-banana-plugin-template.git'
      @command = create_command('claide-banana', alt_repo)

      @command.expects(:git!).with(['clone', alt_repo, 'claide-banana'])
      @command.expects(:configure_template)
      @command.run
      UI_OUT.string.should.include('Creating `claide-banana` plugin')
    end
  end
end
