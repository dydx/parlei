module MemoryRepository
  class UserRepository
    def initialize
      @records = {}
      @id = 1
    end

    def model_class
      MemoryRepository::User
    end

    def new(attributes = {})
      model_class.new(attributes)
    end

    def save(object)
      object.id = @id
      @reocrds[@id] = object
      @id += 1
      return object
    end

    def find_by_id(n)
      @records[n.to_i]
    end
  end
end

class Repository
  def self.register(type, repo)
    repositories[type] = repo
  end

  def self.repositories
    @repositories ||= {}
  end

  def self.for(type)
    repositories[type]
  end
end

configure :test, :development do
  Repository.register(:user, MemoryRepository::UserRepository.new)
end

get "/user/:id" do
  @user = Repository.for(:user).find_by_id(params[:id])
  erb '/users/show'.to_sum
end
