module Lita
  module Handlers
    class Log < Handler
      route(/Finished.*production/, 
        :add_log,
        :help: {
          'Finished something to production' => 'Lita add it to log'
        }
      )
      def add_log ()
         response.reply('INFO ADDDED TO LITA HDFS STORAGE')
      end 
    end

    Lita.register_handler(Log)
  end
end
