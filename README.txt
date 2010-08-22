= codefumes

* http://codefumes.rubyforge.org/codefumes
* Wiki: https://github.com/cosyn/codefumes/wikis
* Repository: https://github.com/cosyn/codefumes
* Official CodeFumes.com gems: http://codefumes.rubyforge.org/
* Website: http://www.codefumes.com

== DESCRIPTION:

CodeFumes.com[http://codefumes.com] is a service intended to help people
involved with software projects who are interested in tracking, sharing,
and reviewing metrics/information about a project in relation to the
commits of said project's repository.  The site supports a small set of
'standard' metrics (# lines changed/commit, build status, build duration,
etc).  Additionally, the service provides a simple method of supplying
and retrieving custom metrics, allowing users to gather any metric they
are interested in tracking.

The 'codefumes' gem is an implementation of the
CodeFumes.com[http://codefumes.com] API. The intention of the
gem is to simplify integration with CodeFumes.com for developers of
other libraries & and applications.

== FEATURES/PROBLEMS:

=== Features
* Saving, finding, marshalling, and destroying CodeFumes
  projects
* Associating and retrieving a repository's history of commits for a
  CodeFumes 'project'
* Simple interface for accessing both CodeFumes's 'standard' commit
  metrics, as well as custom commit attributes; simplifying
  integration with other tools & libraries users may be interested in
  using.
* Interfaces with the CodeFumes config file (used to track projects a
  user has created on the site)
* Tracking & retrieving information about continuous integration server
  builds (duration, status, etc).

=== Problems / Things to Note

* CodeFumes 'projects' are repository-specific, not branch-specific.

== SYNOPSIS:

  require 'codefumes'

  # Creating & finding a CodeFumes project
  p = Project.create
  found_p = Project.find(p.public_key)
  p.public_key # => 'Abc3'
  p.api_uri    # => 'http://codefumes.com/api/v1/xml/Abc3'

  # Commits
  c = Commit.find(<commit identifier>)
  c.identifier    # => git commit SHA (svn support coming soon)
  c.short_message # => commit message

  # Custom attributes associated with a commit
  c.custom_attributes[:coverage] # => "80"

  # Payloads, used to break up large HTTP requests
  content = Payload.prepare(payload_content)
  content.each {|chunk| chunk.save}

== REQUIREMENTS:

* httparty (0.4.3)
* caleb-chronic (0.3.0)
* gli (1.1.1)

== INSTALL:

From Gemcutter:

  gem install codefumes

== LICENSE:

Refer to the LICENSE file

== Contributors
* Joe Banks
