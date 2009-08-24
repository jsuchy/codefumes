module CodeFumes
  class Project < CodeFumes::API

    attr_reader :private_key, :short_uri, :community_uri, :api_uri
    attr_accessor :name, :public_key

    def initialize(options = {})
      @public_key = options[:public_key]
      @private_key = options[:private_key]
      @name = options[:name]
    end

    def delete
      response = destroy!
      case response.code
      when 200
        return true
      else
        return false
      end
    end

    def save
      response = exists? ? update : create
      case response.code
      when 201, 200
        reinitialize!(response)
        true
      else
        false
      end
    end

    def to_config
      {@public_key.to_sym =>
        [ {:private_key => @private_key},
          {:api_uri => @api_uri},
          {:short_uri => @short_uri},
        ]
      }
    end

    def exists?
      return false if @public_key.nil? || @public_key.empty?
      !self.class.find(@public_key).nil?
    end

    def self.find(public_key)
      response = get("/projects/#{public_key}")
      case response.code
      when 200
        project = Project.new
        project.reinitialize!(response)
      else
        nil
      end
    end

    def reinitialize!(options = {})
      @public_key    = options['project']['public_key']
      @private_key   = options['project']['private_key']
      @short_uri     = options['project']['short_uri']
      @community_uri = options['project']['community_uri']
      @api_uri       = options['project']['api_uri']
      self
    end

    private
      def update
        self.class.put("/projects/#{@public_key}", :query => {:project => {:name => @name}, :private_key => @private_key})
      end

      def create
        self.class.post('/projects', :query => {:project => {:name => @name, :public_key => @public_key}})
      end

      def destroy!
        self.class.delete("/projects/#{@public_key}", :query => {:private_key => @private_key})
      end
  end
end
