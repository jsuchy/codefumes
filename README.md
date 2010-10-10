= codefumes

* http://cosyn.github.com/codefumes
* Wiki: https://github.com/cosyn/codefumes/wikis
* Repository: https://github.com/cosyn/codefumes
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

=== In your own Ruby code:

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

  # Build Management
  # QuickBuild grabs local commit head & current time to start build
  QuickBuild.start('build-name-here')

  # QuickBuild grabs local commit head & current time to finish build
  QuickBuild.finish('build-name-here', 'successful')

  # Custom attributes associated with a commit
  c.custom_attributes[:coverage] # => "80"

  # Payloads, used to break up large HTTP requests
  content = Payload.prepare(payload_content)
  content.each {|chunk| chunk.save}


=== From the command line:

  $ fumes sync  # <- synchronizes local repository with CodeFumes.com
  $ fumes build --start ie7
  $ fumes build --finish=successful ie7
  $ fumes build --status --all

  # Link to your CodeFumes account
  $ fumes api-key [your-api-key]
  $ fumes claim

  # Release the project (unlink from your account)
  $ fumes release

  # Delete the project entirely from CodeFumes.com
  $ fumes delete

See 'fumes --help' for more information on available commands and options.

== REQUIREMENTS:

* httparty (0.4.3)
* caleb-chronic (0.3.0)
* gli (1.1.1)
* grit (2.0)

== INSTALL:

From Gemcutter:

  gem install codefumes

== LICENSE:

Refer to the LICENSE file

== Contributors (sorted alphabetically)

* Dan Nawara
* Joe Banks
* Joseph Leddy
* Leah Welty-Rieger
* Roy Kolak
