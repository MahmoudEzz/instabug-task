#config/initializers/redis.rb
$redis = Redis::Namespace.new("redis_with_rails", :redis => Redis.new(host: 'redis', port: 6379))