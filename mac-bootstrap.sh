#!/bin/sh

# mac-bootstrap.sh
# by wilsonmar at gmail.com
# This bash script bootstraps a MacOS laptop (like at https://github.com/fs/osx-bootstrap)
# to run Selenium against a Java source file that
# simply opens a web page in several browsers.
#
# This script installs:
#    - xcode
#    - homebrew
#
# It will ask you for your sudo password.

fancy_echo() { # to add blank line between echo statements:
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

CWD=`pwd`
fancy_echo "Boostrapping into $CWD ..."

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e  # to stop on error.

# Ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Ensure Apple's command line tools are installed
if ! command -v cc >/dev/null; then
  fancy_echo "Installing xcode (Agreeing to the Xcode/iOS license requires sudo admin privileges) ..."
  sudo xcodebuild -license accept
  # xcode-select --install
else
  fancy_echo "Xcode already installed. Skipping."
fi


if brew ls --versions myformula > /dev/null; then
  fancy_echo "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
  ruby --version # ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
else
  fancy_echo "Homebrew already installed. Skipping."
fi


#fancy_echo "Install Caskroom ..."
# brew tap caskroom/cask


if ! command -v java >/dev/null; then
  fancy_echo "Installing Java..."
  brew cask install java
else
  fancy_echo "Java already installed. Skipping."
fi


if ! command -v mvn >/dev/null; then
  fancy_echo "Installing Maven..."
  brew install maven
  mvn --version  # Apache Maven 3.3.9
else
  fancy_echo "Maven already installed. Skipping."
fi


if ! command -v git >/dev/null; then
  fancy_echo "Installing Git..."
  brew install git
  git --version  # git version 2.10.1
else
  fancy_echo "Git already installed. Skipping."
fi


if ! command -v git >/dev/null; then
  fancy_echo "Installing Ruby..."
  brew install ruby
  ruby --version  # git version 2.10.1
  # export PATH=/usr/local/opt/ruby/bin:$PATH
else
  fancy_echo "Ruby already installed. Skipping."
fi

DIRECTORY="Basic-Selenium-Java"
if [ ! -d "$DIRECTORY" ]; then  # directory doesn't exit:
  fancy_echo "Using Git to clone/create \"$DIRECTORY\" from GitHub ..."
  pwd
  git clone https://github.com/wilsonmar/$DIRECTORY.git && cd $DIRECTORY 
else
  fancy_echo "\"$DIRECTORY\" already exists. No need to clone."
fi


if [ -d ".git" ]; then  # directory exits:
  fancy_echo "Copy hooks/git-commit into .git/hooks  ..."
  cp -R hooks/.  .git/hooks/

  HOOK_FILE="commit-msg"
  if [ -f "$HOOK_FILE" ]; then  # file exits:
    cp /hooks/$HOOK_FILE  .git/hooks
    chmod +x .git/hooks/$HOOK_FILE
  fi

  HOOK_FILE="git-commit"
  if [ -f "$HOOK_FILE" ]; then  # file exits:
    cp /hooks/$HOOK_FILE  .git/hooks
    chmod +x .git/hooks/$HOOK_FILE
  fi

  HOOK_FILE="git-push"
  if [ -f "$HOOK_FILE" ]; then  # file exits:
    cp /hooks/$HOOK_FILE  .git/hooks
    chmod +x .git/hooks/$HOOK_FILE
  fi

  HOOK_FILE="git-rebase"
  if [ -f "$HOOK_FILE" ]; then  # file exits:
    cp /hooks/$HOOK_FILE  .git/hooks
    chmod +x .git/hooks/$HOOK_FILE
    # these files are executed by Git when invoked by git events such as commit.
  fi
else
  fancy_echo ".git folder not found. This is not a Git repo! Aborting run."
fi

ls .git/hooks

exit


DIRECTORY_UP="install-all-firefox"
if [ ! -d "$DIRECTORY_UP" ]; then  # directory doesn't exit:
  fancy_echo "$DIRECTORY_UP being cloned..."
  cd ..
  git clone https://github.com/omgmog/$DIRECTORY_UP.git --depth=1 && cd $DIRECTORY_UP 
  chmod +x firefoxes.sh 
  ./firefoxes.sh "current" "en-US" "no_prompt"
  # Delete all files from temporar

  cd $DIRECTORY
else
  fancy_echo "$DIRECTORY_UP already exists. Skipping..."
fi

##############

#HOOK_FILE="mac_install_browsers.sh" 
#if [ -f "$HOOK_FILE" ]; then  # file exits at the root:
  #fancy_echo "Run $HOOK_FILE to establish browser add-ins using brew ..."
  #chmod +x $HOOK_FILE
  # ./$HOOK_FILE
#else
#  fancy_echo "$HOOK_FILE folder not found."

  # If any was already installed, install is skipped:
  brew install geckodriver
  #brew cask install firefox
  brew install chromedriver
  brew install phantomjs  
#fi


#  brew cask install google-chrome
HOOK_FILE="/Applications/Google Chrome.app'" 
if [ ! -f "$HOOK_FILE" ]; then  # file exits at the root:
  fancy_echo "Installing $HOOK_FILE..."
  brew cask install google-chrome
else
  fancy_echo "$HOOK_FILE exists. Skipping."
fi


  brew install phantomjs  

fancy_echo "Run mvn install ..."
mvn install


pwd
fancy_echo "Run test ..."
mvn test -Dsurefire.suiteXmlFiles=mac-only.xml
# Browser windows should open and close on their own.

fancy_echo "Done with status $? (0=OK)."
# EOF #