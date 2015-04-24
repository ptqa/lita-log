class ES
  class << self
    def timestamp
      Time.now.utc.iso8601
    end

    def type_name
      'lita'
    end

    def index_name
      # to get current es index name
      'logstash-' + (Time.now.strftime '%Y.%m.%d')
    end

    def put(msg)
      msg[:'@timestamp'] = timestamp
      msg = {
        index: index_name,
        type: type_name,
        body: msg
      }
      es.index msg
    end

    def health
      es.cluster.health
    end

    def es
      @client ||= Elasticsearch::Client.new url: '127.1:9200'
    end
  end
end
