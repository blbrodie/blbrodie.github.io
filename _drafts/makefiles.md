---
layout: post
title: The Language Agnositic, all purpose, Makefile
categories: Makefile
---


I like to use Makefiles. I like to use Makefiles in Java. I like to
use Makefiles in Erlang. I like to use Makefiles in Elixir. And most
recently, I like to use Makefiles in Ruby. I think you, too,
would like to use Makefiles in your environment, and I the engineering
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

### Use it for yourself even if they don't want it
### Structure of a Makefile
    use tabs
### Just write down the commands you use now. 
    Don't design for the future.
### Makefiles are about files
### Makefiles are not about files
    



