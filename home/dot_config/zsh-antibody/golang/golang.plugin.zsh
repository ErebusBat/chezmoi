# if [[ `type go` =~ 'not found' ]]; then return 0; fi
if [[ `type go` =~ 'not found' ]]; then
  if [[ -x /usr/local/go/bin/go ]]; then
	  export PATH=$PATH:/usr/local/go/bin
  else
		return
	fi
fi

# If not set, use go tool to devine GOPATH
[[ -z $GOPATH ]] && GOPATH=$(go env GOPATH)
if [[ ! -d $GOPATH ]]; then
  # Go is installed, but not setup so don't do anything here
  echo "WARN: Go is installed, but not setup (Could not find $GOPATH)"
  unset GOPATH
  return 0
fi
export GOPATH

#   alias gocoverage="go test -coverprofile=coverage.out && go tool cover -html=coverage.out"
if [[ -d $GOPATH/bin ]]; then
  export PATH=$GOPATH/bin:$PATH
fi

# Setup shortcut to source code, if env is setup
# this is probably not the correct place for this... :thinking:
[[ -z $GITHUB_USER ]] && GITHUB_USER=ErebusBat   # Need to extract this to some sort of .env file
if [[ -n $GITHUB_USER ]]; then
  GOSRCME=$GOPATH/src/github.com/$GITHUB_USER
  # Make sure the source folder exists, but only if GOPATH/src exists
  if [[ -d $GOPATH/src && ! -d $GOSRCME ]]; then
    mkdir -p $GOSRCME
  fi
fi
