---
layout: post
title: The Language Agnositic, all-purpose, incredible, Makefile
categories: Makefile
---

I like to use Makefiles. I like to use Makefiles in Java. I like to
use Makefiles in Erlang. I like to use Makefiles in Elixir. And most
recently, I like to use Makefiles in Ruby. I think you, too,
would like to use Makefiles in your environment, and the engineering
community would benefit if more of us used Makefiles, in general.

Make was born in 1976, making it one of the oldest tools in a
programmer's toolkit. Any tool that has been around this long is bound
to have a mythology, stories, and examples that would be intimidating
to someone unfamiliar with it. Additionally, I think many of us have
written it off as no longer relevant, as we are not writing C
programs, after all. Allow me to show you why it should not be
intimidating, and furthermore, is applicable to your everyday
workflow as an engineer.

### Indicators that you may benefit from a Makefile

There are a number of indicators that a Makefile would do you
good. These indicators are common enough that I'm sure some apply to
you.

1. Do you have aliases or functions in your `.bashrc` that are specific to a project, such as

        alias chrome_rspec="CAPYBARA_JAVASCRIPT_DRIVER=chrome bundle exec bin/rspec"
        alias serve="bundle exec foreman start -f Procfile.dev


2. Do you use a disparate set of commands in a project, in particular those that use many different tools, a complex set of arguments, or environment variables, such as

        RAILS_ENV=test bundle exec rails db:migrate 
        rake db:seed
        bundle exec jekyll serve --drafts --incremental
        bundle exec rspec spec/features/*.rb
        bundle exec rails c

3. Do you keep notes in Evernote, an org file, or a text file to write down commonly used commands for a project?

4. Do you have to run certain commands before others? For example, when switching branches in a rails project, you might have to do something like

        bundle && RAILS_ENV=test bundle exec rails db:migrate && bundle exec rspec spec/features/

### Benefits of a Makefile
0. Commands are local to the project they are used for (as opposed to your .bashrc)
0. Commands are shared with the team, your improvements improves your teammates environment
0. They are version controlled with your project
0. A Makefile is a list of useful commands within the domain of the project. All you have to do is look at it to get an idea of what you can do with a project. It **is** the entry point to the project.
0. It gives you an explicit dependency tree.
0. If you have a command and its not there, just add it! Your team will benefit from it.

### My story

### Teams that don't currently use Makefiles
These days, it isn't surprising to join a startup that does not use
Makefiles. Often, developers in these situations are using the tools
that come with the software environment they are using. If its rails,
they are going to be using `bundle`, `rails`, and `rspec` commands;
this is fine, in fact, with a Makefile, you will still be using these
commands, but the Makefile will be an abstraction *over*
these commands.

### Use it for yourself even if they don't want it
Because a Makefile is simply an abstraction over commonly used tools,
there is no downside to using a Makefile even if your team doesn't yet
see the value in it; they can continue using their workflow while you
use the Makefile. I would suggest committing it into the repository
once you have developed a useful Makefile, and then when someone asks
how to reseed a database, for example, you can mention "Just run make
db-seed".

### What is a Makefile?
There are years of use cases and idiomatic practices that can make
learning about Makefiles daunting. I want to introduce the basics so
you can start using Makefiles right away. Its very simple when we break it down.

The Makefile is a file, usually in the root of a project, with the name `Makefile`.

A `Makefile` is made up of `rules`. A `rule` contains a `target`, `prerequisites`, and `commands`.

    target_1: prerequisite_1 ... prerequisite_n
        command_1
        ...
        command_n
        
#### Target

The target is the thing you want to do (run a test, build code, drop a database, etc).

#### Prerequisite

Prerequisites are the rules needed to run before this rule can run. For example, imagine checking out a new ruby project and executing `bundle exec rspec`; you will probably encounter an error about needing to run `bundle` first! So, running `bundle` is a *prerequisit* of running rspec tests.

If you are thinking "oh, but I don't want to run bundle *every* time", don't worry. Makefiles can determine if a prerequisite needs to be run or not. We'll get to that.

#### Command

A command is a command run in the shell (`sh` by default), and after running the series of commands, it should produce the desired outcome of the target. For example, if your target is `test`, the command might be `bundle exec rspec`.

#### A dead simple example

    file_1: 
        touch file_1

- The target is `file_1`.
- There are no prerequisites.
- The command `touch file_1` produces `file_1`.

If this was a makefile, it could be executed with `make file_1`.

#### A dead simple walkthrough

Let's add another target to the dead simple example.

    file_2: file_1
        touch file_2
        
- The target is `file_2`
- The prerequisite is `file_1`
- The command is `touch file_2`
        
        
At this point, I strongly recommend you follow along with your own makefile. You will learn by doing. Create a makefile so that it looks like this:

    file_1:
        touch file_1

    file_2:
        touch file_2

And *be sure to use tabs to indent the commands*. This is a requirement that trips up every person new to Make. If you do not use tabs, you will receive an error that looks like this `Makefile:5: *** missing separator.  Stop.`

Now, if we run `make file_2`, it will first check for the target `file_1`, and if that target does not exist, it will run the command to fulfill `file_1`.

    $ make file_2
    touch file_1
    touch file_2

If we subsequently run `make file_2`, we will see a message like this `make: 'file_2' is up to date.` Make is telling us it doesn't have to do anything because `file_2` already exists.

    $ make file_2
    make: `file_2' is up to date.

Let's `rm file_2`, and then we see that `make file_2` will `touch file_2` but it will not `touch file_1`.

    $ rm file_2
    $ make file_2
    touch file_2
    
Can you predict what happens if we `make file_2` at this point? If you are thinking it will say `up to date` again, you are getting it!

    $ make file_2
    make: `file_2' is up to date.
    
Okay, so what will happen if we `touch file_1` and subsequently `make file_2`?

    $ make file_2
    touch file_2
    
Well, that's a new fact about the world, isn't it? We haven't seen
this before? Let's explore what is going on here.

Okay, quick tangent here. When we touch a file, what happens? If the file doesn't exist, it creates that file; but what if that file already exists?
    
    $ ls -ahl file_1
    -rw-r--r--  1 ben.brodie  staff     0B Aug  9 06:48 file_1
    $ touch file_1
    $ ls -ahl file_1
    -rw-r--r--  1 ben.brodie  staff     0B Aug  9 06:50 file_1
    
Do you spot the difference? It updates the _timestamp_. Let's look at this again.

    $ ls -ahl
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 06:50 file_1
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:10 file_2
    $ make file_2
    make: `file_2' is up to date.
    $ touch file_1
    $ ls -ahl
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:13 file_1
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:10 file_2
    $ make file_2
    touch file_2
    _drafts$ ls -ahl
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:13 file_1
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:13 file_2
    $ make file_2
    make: `file_2' is up to date.
    
Do you see what's happening here? If the timestamp of the prerequisite is _more recent_ than the timestamp of the current target, then the command for the current target will run. This is how makefiles determine if the command of a target should be run.

#### I Can't Get No Preqrequisite Satisfaction

Feeling a bit like you are on an island? We have looked into the mechanics of the `Make` operations, and the syntax of the `Makefile`, but how does this all work together, and what is the _point_ of all this anyways? If it hasn't clicked yet, _that's okay_; we are going to get there, I promise.

It will be helpful for a moment to think of the `Makefile` as a tree, where each node represents a `target`, and an edge represents a target's relationship to it's prerequisites.

    file_1 -- file_2
           \- file_3

Here we have three targets: `file_1`, `file_2`, and `file_3`. `file_2` and `file_3` both have one prerequisite, `file_1`, and since they are leaves, they are not the prerequisite of any other targets.

Represented in a makefile, it could look like this:

    file_1: 
        touch file_1
      
    file_2: file_1
        touch file_2
        
    file_3: file_1
        touch file_3
        
Following? If not, that's okay, just reread this section - it's a key concept.





    


    






### Just write down the commands you use now. 
They key to successfully writing a Makefile is to just write down the
commands you need at the moment. Ran a new command? Put it in the
Makefile. Over time, the Makefile will grow to include even those rare
commands you rarely run and can't remember what they were. 

Do not try to come up with all the commends you will need and write
them down at once; it is too difficult to do this upfront, and most
likely will not result in a useful Makefile. Instead, while developers
are working and need a new command, they should commit them into the
Makefile at that point.
### Makefiles are about files
### Makefiles are not about files
### Make vs Rake vs ...
This is the wrong question to be asking. These tools are not diametrically opposed, rather, work together quite effectively.
    



