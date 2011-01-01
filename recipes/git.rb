run 'rm -f .gitignore'
file '.gitignore', <<-EOF
*.swp
**/*.swp
.bundle
Gemfile.lock
EOF

file 'db/.gitignore', "*.sqlite3\n"
file 'log/.gitignore', "*\n"
file 'tmp/.gitignore', "*\n"
file 'vendor/.gitignore', "*\n"

run "find . -type d -empty | egrep -v '(.git|tmp)' | xargs -I xxx touch 'xxx/.gitkeep'"

git :init
git :add => '.', :commit => "-m 'initial commit'"
