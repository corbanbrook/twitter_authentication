require 'twitter_authentication/rails_commands'
class TwitterAuthenticatedGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false
           
                  
  attr_reader   :sessions_name,
                :sessions_class_path,
                :sessions_file_path,
                :sessions_class_nesting,
                :sessions_class_nesting_depth,
                :sessions_class_name,
                :sessions_singular_name,
                :sessions_plural_name,
                :sessions_file_name

  alias_method  :sessions_table_name, :sessions_plural_name

  attr_reader   :users_name,
                :users_class_path,
                :users_file_path,
                :users_class_nesting,
                :users_class_nesting_depth,
                :users_class_name,
                :users_singular_name,
                :users_plural_name

  alias_method  :users_file_name,  :users_singular_name

  alias_method  :users_table_name, :users_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @sessions_name = args.shift || 'sessions'
    @users_name = @name.pluralize

    # sessions controller
    base_name, @sessions_class_path, @sessions_file_path, @sessions_class_nesting, @sessions_class_nesting_depth = extract_modules(@sessions_name)
    @sessions_class_name_without_nesting, @sessions_file_name, @sessions_plural_name = inflect_names(base_name)
    @sessions_singular_name = @sessions_file_name.singularize

    if @sessions_class_nesting.empty?
      @sessions_class_name = @sessions_class_name_without_nesting
    else
      @sessions_class_name = "#{@sessions_class_nesting}::#{@sessions_class_name_without_nesting}"
    end

    # model controller
    base_name, @users_class_path, @users_file_path, @users_class_nesting, @users_class_nesting_depth = extract_modules(@users_name)
    @users_class_name_without_nesting, @users_singular_name, @users_plural_name = inflect_names(base_name)
    
    if @users_class_nesting.empty?
      @users_class_name = @users_class_name_without_nesting
    else
      @users_class_name = "#{@users_class_nesting}::#{@users_class_name_without_nesting}"
    end
  end

  def manifest
    recorded_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions sessions_class_path, "#{sessions_class_name}Controller", "#{sessions_class_name}Helper"
      m.class_collisions users_class_path, "#{users_class_name}Controller", "#{users_class_name}Helper"
      m.class_collisions [], 'TwitterAuthenticatedSystem', 'TwitterAuthenticatedTestHelper'

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/controllers', sessions_class_path)
      m.directory File.join('app/controllers', users_class_path)
      m.directory File.join('app/helpers', sessions_class_path)
      m.directory File.join('app/views', sessions_class_path, sessions_file_name)

      m.directory File.join('app/controllers', users_class_path)
      m.directory File.join('app/helpers', users_class_path)
      m.directory File.join('app/views', users_class_path, users_file_name)

      m.directory File.join('test/functional', sessions_class_path)
      m.directory File.join('test/functional', users_class_path)
      m.directory File.join('test/unit', class_path)

      m.template 'twitter_oauth.yml', 'config/twitter_oauth.yml'

      # initialize the user model template
      m.template 'user.rb', File.join('app/models', class_path, "#{file_name}.rb")

      # initialize the sessions controller template
      m.template 'sessions_controller.rb', File.join('app/controllers', sessions_class_path, "#{sessions_file_name}_controller.rb")

      # initialize the users controller template
      m.template 'users_controller.rb', File.join('app/controllers', users_class_path, "#{users_file_name}_controller.rb")

      # initialize the twitter_authenticated_system library template
      m.template 'twitter_authenticated_system.rb', File.join('lib', 'twitter_authenticated_system.rb')

      # initialize the sessions helper template
      m.template 'sessions_helper.rb', File.join('app/helpers', sessions_class_path, "#{sessions_file_name}_helper.rb")

      # initialize the users helper template
      m.template 'users_helper.rb', File.join('app/helpers', users_class_path, "#{users_file_name}_helper.rb")

      # Controller templates
      m.template 'login.html.erb',  File.join('app/views', sessions_class_path, sessions_file_name, "index.html.erb")

      # Unit tests and fixtures
      #m.template 'authenticated_test_helper.rb', File.join('lib', 'authenticated_test_helper.rb')
      #m.template 'functional_test.rb', File.join('test/functional', sessions_class_path, "#{sessions_file_name}_sessions_test.rb")
      #m.template 'model_functional_test.rb', File.join('test/functional', users_class_path, "#{users_file_name}_sessions_test.rb")
      #m.template 'unit_test.rb', File.join('test/unit', class_path, "#{file_name}_test.rb")
      #m.template 'fixtures.yml', File.join('test/fixtures', "#{table_name}.yml")

      

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
      
      #m.route_resource  sessions_singular_name
      m.route_resources users_plural_name
    end

    action = nil
    action = $0.split("/")[1]
    case action
    when "generate"
      puts
      puts "Generating twitter_authentication."
      puts
      puts "Try these for some familiar login URLs if you like:"
      puts
      puts %(map.login '/login', :controller => '#{sessions_file_name}', :action => 'login')
      puts %(map.logout '/logout', :controller => '#{sessions_file_name}', :action => 'logout')
      puts %(map.callback '/callback', :controller => '#{sessions_file_name}', :action => 'callback')
      puts
      puts "Remember to look over the create_users migration to add fields you require. The #{class_name} model is"
      puts "bootstrapped to the authenticated twitter user. Use the #{class_name} model to store additional fields"
      puts "or to cache twitter account information."

    when "destroy"
      puts
      puts "Removing twitter_authentication."
      puts
    else
      puts
    end

    recorded_session
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} twitter_authenticated ModelName [ControllerName]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
end
