if [[ ! -d ~/src/sie ]]; then return 0; fi

# Command that vim
alias vimrspec='bundle exec spring rspec -f d'

if [[ `uname` == 'Darwin' ]]; then
  # Fixes crazy error: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
  # https://www.jdeen.com/blog/fix-ruby-macos-nscfconstantstring-initialize-error
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
fi
