require 'rubygems'
require 'bundler/setup'
require 'tzinfo'
require 'nokogiri'
require_relative 'version_file.rb'
require_relative 'version_config_file.rb'
require_relative 'core_ext.rb'

class VamperTool

  def initialize
    @do_update = false;
    @version_file_name = ''
    @today = Date.today
  end

  def parse(args)
    args.each { |arg|
      case arg
        when '-?', '-help'
          print %q(
Version Stamper. Release Version 3.0.10708.2
Copyright (c) John Lyon-Smith 2015.

Syntax:               vamper_tool.rb [switches] VERSION_FILE

Description:          Stamps versions into project files

Switches:

    -help|-?          Shows this help
    -u|-update        Increment the build number and update all files
)
          exit(0)
        when '-u', '-update'
          @do_update = true
        else
          @version_file_name = arg
      end
    }
  end

  def execute
    self.parse(ARGV)

    if @version_file_name.length == 0
      find_version_file
    end

    @version_file_name = File.expand_path(@version_file_name)

    project_name = File.basename(@version_file_name, '.version')
    version_config_file_name = "#{File.dirname(@version_file_name)}/#{project_name}.version.config"

    puts "Version file is '#{@version_file_name}'"
    puts "Version config is '#{version_config_file_name}'"
    puts "Project name is '#{project_name}'"

    if File.exists?(@version_file_name)
      version_file = VersionFile.new(File.open(@version_file_name))
    else
      verson_file = VersionFile.new
    end

    case version_file.build_value_type
      when :JDate
        build = get_jdate(version_file.start_year)

        if version_file.build != build
          version_file.revision = 0
          version_file.build = build
        else
          version_file.revision += 1
        end
      when :FullDate
        build = get_full_date

        if version_file.build != build
          version_file.revision = 0
          version_file.build = build
        else
          version_file.revision += 1
        end
      when :Incremental
        version_file.build += 1
        version_file.revision = 0
    end

    puts 'Version data is:'
    tags = version_file.tags
    tags.each { |key, value|
      puts "  #{key}=#{value}"
    }

    if @do_update
      puts 'Updating version information:'
    end

    unless File.exists?(version_config_file_name)
      FileUtils.cp(File.join(File.dirname(__FILE__), 'default.version.config'), version_config_file_name)
    end

    version_config_file = VersionConfigFile.new(File.open(version_config_file_name), tags)
    file_list = version_file.files.map { |file_name| file_name.replace_tags!(tags) }

    file_list.each do |file_name|
      path = File.expand_path(File.join(File.dirname(@version_file_name), file_name))
      path_file_name = File.basename(path)

      version_config_file.file_types.each do |file_type|
        if file_type.file_specs.any? { |file_spec| file_spec.match(path_file_name) }
          if file_type.write
            if File.exists?(path)
               if @do_update
                 file_type.updates.each { |update|
                   content = IO.read(path)
                   content.gsub!(%r(#{update.search})m, update.replace.gsub(/\${(?<name>\w+)}/,'\\\\k<\\k<name>>'))
                   IO.write(path, content)
                 }
               end
            else
              error "File #{path} does not exist to update"
              exit(1)
            end
          else # !file_type.write
            dir = File.dirname(path)
            unless Dir.exists?(dir)
              error "Directory '#{dir}' does not exist to write file ''#{path_file_name}''"
              exit(1)
            end

            if @do_update
              IO.write(path, file_type.write)
            end
          end
        else
          error "File '#{path}' has no matching file type in the '#{version_config_file_name}'"
          exit(1)
        end

        puts path
      end

      if @do_update
        version_file.write_to(@version_file_name)
      end
    end
  end

  def find_version_file
    dir = Dir.pwd

    while dir.length != 0
      files = Dir.glob('*.version')
      if files.length > 0
        @version_file_name = files[0]
        break
      else
        if dir == '/'
          dir = ''
        else
          dir = File.expand_path('..', dir)
        end
      end
    end

    if @version_file_name.length == 0
      error 'Unable to find a .version file in this or parent directories.'
      exit(1)
    end
  end

  def get_full_date
    @today.year * 10000 + @today.month * 100 + @today.mday
  end

  def get_jdate(start_year)
    ((@today.year - start_year + 1) * 10000) + (@today.month * 100) + @today.mday
  end

  def error(msg)
    puts "ERROR: #{msg}"
  end

end

VamperTool.new.execute