# written by Miki Olsz / (c) 2020 Unforgiven.pl
# released under Apache 2.0 License

require 'github_api'

unless ARGV.size >= 3 && ARGV[2].include?('/') && %w[true false -].include?(ARGV[6]) && %w[success fail change -].include?(ARGV[10])
  puts <<~HELP
    incorrect parameter syntax or less than two parameters provided, which is probably NOT what was intended
    this script supports the following parameters:
      0 = source branch      (required)
      1 = target branch      (optional; default or '-' means repository's default branch)
      2 = path/repository    (required)
      3 = auth token         (requited; token must have privileges to create PRs in given repository)
      4 = title of PR        (required if a PR is to be created, optional if there already is one)
      5 = body of PR         (optional; '-' means empty)
      6 = draft flag status  (optional; defaults to "false"; only "true" and "false" are allowed)
      7 = assignees of PR    (optional; '-' means empty, otherwise coma-separated logins of existing users)
      8 = labels of PR       (optional; labels must be comma-separated and exist in the repository; '-' means none)
      9 = milestone of PR    (optional; number of the milestone to add the PR to; '-' means none)
     10 = overwrite strategy ("success", "fail" - default or "change"; defines what to do when an open PR already exists)
  HELP
end

user, repository = *ARGV[2].split('/')
token = ARGV[3]
source = ARGV[0]
prefixed_source = source.include?(':') ? source : [user, source].join(':')
github = Github.new(oauth_token: token)
begin
  target = (ARGV[1] != '-' && ARGV[1]) || github.repositories.get(user: user, repo: repository)[:default_branch]
  puts "looking for an existing, open PR from #{source} to #{target} in #{user}/#{repository}..."
  existing_pr = github.pulls.list(user: user, repo: repository, base: target, head: prefixed_source).first
  if existing_pr.nil?
    puts '...none found; attempting to create a new PR...'
    puts('error: title not set') && exit(500) if ARGV[4].nil? || ARGV[4].empty? || ARGV[4] == '-'

    pr_body = ARGV[5]
    pr_body = '' if pr_body == '-'

    pr_draft = ARGV[6] == 'false'

    created_pr = github.pulls.create(user: user, repo: repository, head: prefixed_source, base: target, title: ARGV[4], body: pr_body, draft: pr_draft)
    pr_number = created_pr.number
    puts "...created new PR with number #{pr_number}"

  elsif existing_pr && %w[fail -].include?(ARGV[10])
    puts "...found PR #{existing_pr.number}, cannot continue"
    exit 400
  elsif existing_pr && ARGV[10] == 'success'
    puts "...found PR #{existing_pr.number}, so not doing anything"
    exit 0 # great success! :)
  else
    puts "...found PR #{existing_pr.number}, updating..."
    # modifying - title, body, draft can be modified through pull request api
    updates = {}
    [[:title, 4], [:body, 5], [:draft, 6]].each { |attr, index| updates[attr] = ARGV[index] unless ARGV[index].nil? || ARGV[index].empty? || ARGV[index] == '-' }
    github.pulls.edit(updates.merge(user: user, repo: repository, pull_number: existing_pr.number)) unless updates.empty?
    puts "...updated #{updates.size} properties of PR #{existing_pr.number}"
    # labels, assignees and milestone can be modified through issues api and will be done also for newly created issue
    pr_number = existing_pr.number
  end

  puts "setting properties of issue #{pr_number}..."
  updates = {}
  [[:assignees, 7], [:labels, 8]].each { |attr, index| updates[attr] = ARGV[index] unless ARGV[index].nil? || ARGV[index].empty? || ARGV[index] == '-' }
  updates[:milestone] = ARGV[9] if ARGV[9] =~ /^\d+$/
  github.issues.edit(updates.merge(user: user, repo: repository, number: pr_number)) unless updates.empty?
  puts "...updated #{updates.size} properties of the issue"

  puts 'all done; thank you!'

rescue Github::Error::NotFound => e
  puts e.message
  puts 'stack trace for reference:'
  puts e.backtrace.inspect
  exit 404
end
