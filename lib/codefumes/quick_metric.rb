module CodeFumes
  class QuickMetric
    # Associates a Hash of +custom_attributes+ with the current commit
    # identifier of the repository located at +repository_path+.
    #
    # Returns +true+ if the request succeeded.
    #
    # Returns +false+ if the request failed.
    def self.save(custom_attributes, repository_path = './')
      repo = SourceControl.new(repository_path)
      commit = {:identifier => repo.local_commit_identifier,
                :custom_attributes => custom_attributes
               }
      content = {:content => {:commits => [commit]}}
      project = Project.new(repo.public_key, :private_key => repo.private_key)
      payload_set = Payload.prepare(project, content)
      payload_set.reject {|payload| payload.save}.empty?
    end
  end
end
