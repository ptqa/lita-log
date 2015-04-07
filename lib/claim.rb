class Claim
  REDIS_NAMESPACE = 'handlers:claims'
  REDIS_KEY = 'claim'

  class << self
    def all
      redis.hkeys(REDIS_KEY)
    end

    def create(property_name, claimer, environment = 'default')
      return false if self.exists?("#{property_name}_#{environment}")
      redis.hset(REDIS_KEY, "#{property_name}_#{environment}", claimer)
    end

    def read(property_name, environment = 'default')
      redis.hget(REDIS_KEY, "#{property_name}_#{environment}")
    end

    def destroy(property_name, environment = 'default')
      redis.hdel(REDIS_KEY, "#{property_name}_#{environment}")
    end

    def exists?(property_name, environment = 'default')
      redis.hexists(REDIS_KEY, "#{property_name}_#{environment}")
    end

    def redis
      @redis ||= Redis::Namespace.new(REDIS_NAMESPACE, redis: Lita.redis)
    end
  end
end
