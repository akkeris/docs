# Installing and Prerequisites

## Prerequisites

To fully take advantage of Akkeris ensure you install all the prerequisites:

1. [Node.js 8+](https://nodejs.org)
2. [Docker CLI](https://www.docker.com/products/docker-desktop)
3. [Git CLI](https://git-scm.com/book/en/v2/Getting-Started-The-Command-Line)

You'll also need to ensure you have:

1. An account on Akkeris
2. [Github Account](https://github.com) (optional)

### Using apt (Debian/Ubuntu)

Ensure package versions are up to date
```shell
sudo apt update
```

Install Docker
```shell
sudo apt install -y docker
```

Install Node.js via [NodeSource](https://github.com/nodesource/distributions/blob/master/README.md):
```shell
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs
```

Install Git
```shell
sudo apt install -y git
```

### Using [Homebrew](https://brew.sh/) (MacOS)

Install Docker
```shell
brew install docker
```

Install Node.js
```shell
brew install node
```

Install Git
```shell
brew install git
```

### Using pacman (ArchLinux)

Install Docker
```shell
pacman -Sy docker
```

Install Node.js
```shell
pacman -Sy nodejs npm
```

Install Git
```shell
pacman -Sy git
```

### Windows

While basic functionality _should_ be available via versions of [Git](https://gitforwindows.org/), [Docker](https://www.docker.com/products/docker-desktop), and [Node.js](https://nodejs.org/en/) for Windows OS, Akkeris CLI is tested on and designed for Linux and MacOS operating systems. 

The easiest way to get up and running with Akkeris on Windows 10 is to install [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and [Debian](https://www.microsoft.com/store/apps/9MSVKQC78PK6), and then follow the [apt prerequisite instructions](#using-apt-debianubuntu).

## Installing

In this step you will install the Akkeris Command Line Interface \(CLI\). You can use the CLI to manage and scale your applications, to provision add-ons, to install plugins from other engineers on your teams, to view the logs of your application as it runs on Akkeris, to pull logs from legacy apps, as well as to help run your application locally.

Install Akkeris:

```shell
npm -g install akkeris
```

_Note, if you receive an error about insufficient permissions you may need to run _`sudo npm -g install akkeris`_ instead._

Then type `aka`:

```shell
aka

Hi! It looks like you might be new here. Lets take a second
to get started, you'll need your akkeris auth and apps host
in addition to your login and password.

Akkeris Auth Host (auth.example.io): auth.example.io
Akkeris Apps Host (apps.example.io): apps.example.io
Profile updated!
Username: first.lastname
Password: ******
Logging you in ...  ✓
```

Note that after you login you may see a list of available commands.

## Setting Up Github Account on the CLI

It's a fairly common complaint that after enabling github two factor authentication that command line utilities to stop working.  The underlying issue is command line utilities send your username and password with each request to github, using two factor authentication disables github from accepting just your username and password, so your command line utilities such as \`git\` appear to stop working.  Github will still accept a personal access token instead of your password however.

### Setting Up Github on OSX

You'll need to store your Github Personal access token in your netrc as two factor authentication prevents your username/password from being used on the command line.   To fix this follow these steps:

1. Go to [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)
2. Put in the name "Command Line" for the Token Description
3. For the scopes, **enable all the top scopes** \(e.g., click the checkboxes: repo, admin:org, etc, etc...\) 
4. Click `Generate Token`
5. You'll need to copy the token it generates, it's in a green window with a clipboard icon next to it.
6. Open a terminal window \(Go to the Applications folder, Utilities folder, run Terminal application\)
7. Run `touch ~/.netrc; open -a "TextEdit" ~/.netrc` \(or the CLI editor of your choice\)
8. Enter:

   ```
   machine github.com
   login [your_github_login_name]
   password [the_token_copied_from_above]
   machine api.github.com
   login [your_github_login_name]
   password [the_token_copied_from_above]
   ```

   Make sure to replace \[your\_github\_login\_name\] with your github login, NOT your email address.  Make sure to replace \[the\_token\_copied\_from\_above\] with the token.

9. Save these changes, and close the editor.

10. Run `chmod 600 ~/.netrc` in the Terminal

11. To test this run `curl -n https://api.github.com/user`, you should see your user information in a JSON response.  You can also test this by trying to clone out a private https repo, it should no longer ask for your password.

### Setting up Github on Windows

1. Install git system wide, \(see [https://git-scm.com/download/win](https://git-scm.com/download/win%29%29\)

2. Install Microsoft Github/Git Credential Manager \(see [https://github.com/Microsoft/Git-Credential-Manager-for-Windows/releases/tag/v1.12.0](https://github.com/Microsoft/Git-Credential-Manager-for-Windows/releases/tag/v1.12.0%29%29\)

3. If you're using SourceTree or another software that uses github, make sure its set to use the system wide git and not its embedded one.

4. Use things as normal, when prompted you'll be asked for your username and password; you may also be asked for your two factor auth token when logging in \(it'll auto magically appear as a pop up when needed\)


## Next Steps

* [Deploy your first application](/)