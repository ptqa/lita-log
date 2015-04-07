module Lita
  module Handlers
    class Log < Handler
      config :data_dir, default: '/opt/lita/data'
      config :channel, default: nil
      config :env_list, default: ['production']

      attr_accessor :data

#      http.get "/:env/current", :env_current
      http.get "/", :all_current

      route(/Finished deploying.*/,
        :add_log,
        help: {
          'Finished deploying something to env' => 'Lita add it to log'
        }
      )

      def initialize(robot)
        super
        self.data = {}
        check_dir()
        load_data()
      end

      def check_dir()
        Dir.mkdir(config.data_dir) unless Dir.exist?(config.data_dir)
      end

      def load_data()
        Dir.foreach(config.data_dir) do |file|
          next unless file =~ /.json/
          env = file.chomp('.json')
          self.data[env] = JSON.parse(IO.read("#{config.data_dir}/#{file}"))
        end
      end

      def save_data()
        self.data.each do |env, data|
          filename = "#{config.data_dir}/#{env}.json"
          File.write(filename, self.data[env].to_json)
          puts "#{env} found and saved to #{filename}"
        end
      end

      def save_env(env, hash)
        self.data[env] = [] unless self.data[env]
        self.data[env] << hash
        save_data()
      end

      def add_log (response)
        msg = response.message.body.split(" Finished deploying ")
        user = msg.first
        params = msg.last.split(" ")
        if params.first =~ /webfront/
          project = params.first + " " + params[1]
          commit = params[2]
        else
          project = params.first
          commit = params[1]
        end
        env = params.last.chop!
        save_env(env,{ timestamp: Time.now.to_i, user: user, project: project, commit: commit })
      end

      def env_latest (env)
        return self.data[env].last
      end

      def all_current (request, response)
        all = {}
        self.data.each_key do |env|
          all[env] = env_latest(env)
        end
        html = render_template("index", variables: all)
        response.body << html
      end 

      def env_current (request, response)
        env = request.env['router.params'][:env]
        html = render_template("index")
        if self.data[env]
          response.body << html
        else
          response.body << "Nothing on #{env} yet."
        end
      end 
    end
    Lita.register_handler(Log)
  end
end
