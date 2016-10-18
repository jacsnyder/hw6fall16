class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movies=[]
      if !Tmdb::Movie.find(string).nil?
        Tmdb::Movie.find(string).each do |m|
          selection = Hash.new(0);
          selection[:tmdb_id]=m.id;
          selection[:title]=m.title;
          selection[:release_date]=m.release_date;
          selection[:rating]=find_rating(m.id);
          movies.push(selection);
        end
      end
      return movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      details = Tmdb::Movie.detail(id)
      movie = Hash.new
      movie[:title] = details["title"]
      movie[:rating] = find_rating(id)
      movie[:description] = details["overview"]
      movie[:release_date] = details["release_date"]
      Movie.create!(movie)
      rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.find_rating(id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      all_details = Tmdb::Movie.releases(id)
      specific_details = all_details["countries"].select { |country| country["iso_3166_1"] == "US" }
      if specific_details.size>0
        rating = specific_details[0]["certification"]
      else
        rating = ""
      end
      return rating
      rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
end