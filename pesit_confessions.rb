require "rest-client"
require "json"
require "redis"

class PesitConfessions
  class << self
    def configure
      @access_token = "166959483452298|gTCLDoLCM89lzRvjm_Ww2ThOfsU" #thanks to akshayms ;)
      @api = "https://graph.facebook.com/613660905316922/posts"
      configure_redis
    end

    def configure_redis
      @redis = Redis.new(:host => "localhost", :port => 6379)
      self
    end

    def get_posts(api)
      JSON.parse(RestClient.get(URI.encode(api)))
    end

    def paginate_next(posts)
      posts["paging"]["next"] rescue nil
    end

    def scrape_all_confessions
      posts = get_posts(construct_url(@api))
      process_posts(posts)
      while(next_page = paginate_next(posts))
        posts = get_posts(next_page)
        process_posts(posts)
      end
    end

    def process_posts posts
      posts["data"].each do |post|
        entry = {}
        message = post["message"]
        id = message.match(/Confession #([^\n]+)/)[1] rescue nil

        #next if not a coffession
        next if id.nil?

        entry["message"] = message
        process_confession(message.downcase)
        entry["likes"] = post["likes"]["count"] if post["likes"]
        comments = post["comments"]
        entry["comments_count"] = comments["count"] if comments
        entry["comments"] = comments["data"].collect! {|c| c["message"]} if comments && comments["data"]
        create_a_redis_entry(id, entry)
      end
    end

    def process_confession confession
      person_involved = ["he", "she", "teacher", "guy", "boy", "chick", "girl", "woman", "man"]
      crush_filters = ["gorgeous", "love", "crush", "luv", "<3", "beautiful", "handsome", "lovely", "cute", "attract"]
      love_lines = ["love.*her", "like *her", "i.*love", "i.*crush", "so.*cute"]
      crush_meter = 0
      crush_filters.each do |filter|
        crush_meter += 1 if confession.include?(filter)
      end
      person = 0
      person_involved.each do |filter|
        person += 1 if confession.include?(filter)
      end
      ll = 0
      love_lines.each do |line|
        ll += 1 if confession.match(line)
      end
      puts "crush #{confession}" if (confession.length < 300) && ( (crush_meter >= 1 && person >= 1) || ll >= 1 )
    end

    def create_a_redis_entry id, post
      @redis.hset("posts", id.to_i.to_s, post)
    end

    def construct_url url
      get_access_token unless @access_token
      url + "?access_token=" + @access_token
    end

    def get_access_token
      #to be implemented
    end
  end
end


