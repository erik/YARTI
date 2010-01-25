#:title:YARTI (Yet Another Ruby Twitter Implementation)
# =Purpose
#This library was just meant to test out my Ruby skills, and make me
#try some things I hadn't tried out before. It is, in my opinion, fairly
#useful, and I hope you will find it at least informative.
#
#TODO: finish writing API methods
#TODO: Parse XML, atom, RSS, JSON, etc.
#TODO: Implement http://en.wikipedia.org/wiki/URL_encoding
module YARTI
  class Twitter
    require 'net/http'
    require 'uri'
    require 'open-uri'

    def initialize(user=nil, pass=nil)
      @user = user
      @pass = pass
    end

    #A method to set credentials (username and password)
    #should be used if initialize is called with no arguments
    def setCreds(user = nil, pass = nil)
      if not user and not pass
        raise "You must define at least a username, or a password"
      else
        @user = user
        @pass = pass
      end
    end

    def get(site)
      Net::HTTP.get URI.parse(site)
    end

    def getWithAuth(site)
      if not @user or not @pass
        raise "You must be authenticated to do this"
      end

      url = URI.parse(site)
      req = Net::HTTP::Get.new(url.path)
      req.basic_auth @user, @pass
      Net::HTTP.start("api.twitter.com") {|http|
        req = Net::HTTP::Get.new(site)
        req.basic_auth @user, @pass
        response = http.request(req)
        #print response.body
      }
      req.body.to_s
    end

    def postWithAuth(site, form_data)
      url = URI.parse(site)
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth @user, @pass
      req.set_form_data(form_data)
      res = Net::HTTP.new(url.host, url.port).start { |http|
        http.request(req)
      }
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        #phew!
      else
        res.error!
      end
    end

    #Get statuses pulled from home timeline
    def getHomeTimeline()
      self.getWithAuth("/1/statuses/home_timeline.atom")
    end

    #View the trending topics
    def trends()
      base = "http://search.twitter.com/trends/current.json"
      self.get(base)
    end

    #View current trends
    def trendsCurrent(no_hashtags = nil)
      base = "http://search.twitter.com/trends/current.json"
      base += '?exclude=hashtags' if no_hashtags
      self.get(base)
    end

    #View daily trends
    def trendsDaily(no_hashtags = nil)
      base = "http://search.twitter.com/trends/daily.json"
      base += '?exclude=hashtags' if no_hashtags
      self.get(base)
    end

    #View weekly trends
    def trendsWeekly(no_hashtags = nil)
      base = "http://search.twitter.com/trends/weekly.json"
      base += '?exclude=hashtags' if no_hashtags
      self.get(base)
    end

    #
    #Searches Twitter for a query, with optional parameters for language, locale,
    #results per page, page number, and since the status
    def search(query, lang = nil, locale = nil, rpp = nil, page = nil, since_id = nil)
      base = "http://search.twitter.com/search.atom?"

      base += 'lang='+lang+'&' if lang

      base += 'q='+ query

      base += '&locale='+locale if locale
      base += '&rpp='+rpp.to_s if rpp
      base += '&page='+page.to_s if page
      base += '&since_id='+since_id.to_s if since_id

      self.get(base)
    end

    def searchUsers(query, per_page = nil, page = nil)
      base = 'http://api.twitter.com/1/users/search.xml'
      form_data = Hash.new
      form_data['q'] = query.url_encode
    end

    def updateStatus(status, in_reply_to = nil) #need to implement geo params!
      #findUserByID(in_reply_to) if in_reply_to.kind_of? Numeric
      base = "http://twitter.com/statuses/update.xml"
      status = status[0...140] #truncate to 140 chars

      form_data = Hash.new
      form_data['status'] = status
      form_data['in_reply_to_id'] = in_reply_to if in_reply_to #change this to let them use username instead of ID
      #postWithAuth(base)
      postWithAuth(base, form_data)

    end

    def url_encode this
      this
    end

    def findIDByUser(user)
      base = 'http://twitter.com/users/show.xml?screen_name='+user
      xml = self.get(base)
      id = String.new(xml.to_s[/<id>[0-9]+<\/id>/])
      p id
      id.delete! "<id>"
      id.chop!
      id.to_i

    end

  end
end

