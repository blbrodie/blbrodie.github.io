---
layout: post
title: The Language Agnositic, All-Purpose, Incredible, Makefile
categories: Makefile
---

I like to use Makefiles. I like to use Makefiles in Java. I like to
use Makefiles in Erlang. I like to use Makefiles in Elixir. And most
recently, I like to use Makefiles in Ruby. I think you, too,
would like to use Makefiles in your environment, and the engineering
community would benefit if more of us used Makefiles, in general.

`Make` was born in 1976, making it one of the oldest tools in a
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

1. You have aliases or functions in your `.bashrc` that are specific to a project, such as

        alias chrome_rspec="CAPYBARA_JAVASCRIPT_DRIVER=chrome bundle exec bin/rspec"
        alias serve="bundle exec foreman start -f Procfile.dev


2. You use a disparate set of commands in a project, in particular those that use many different tools, a complex set of arguments, or environment variables, such as

        RAILS_ENV=test bundle exec rails db:migrate 
        rake db:seed
        bundle exec jekyll serve --drafts --incremental
        bundle exec rspec spec/features/*.rb
        bundle exec rails c

3. You keep notes in Evernote, an org file, or a text file to write down commonly used commands for a project.

4. You have to run certain commands before others? For example, when switching branches in a rails project, you might have to do something like

        bundle && RAILS_ENV=test bundle exec rails db:migrate && bundle exec rspec spec/features/

### Benefits of a Makefile

0. Commands are local to the project they are used for (as opposed to your .bashrc)
0. Commands are stored in the project, so improvements are mutually shared.
0. Commands are version controlled with your project.
0. A Makefile is a list of useful commands within the domain of the project. All you have to do is look at it to get an idea of what you can do with a project. It **is** the entry point to the project.
0. The Makefile gives you an explicit dependency tree.
0. If there is a missing command, you can just add it! Your team will benefit from it.

### Teams that don't currently use Makefiles

These days, it isn't surprising to join a startup that does not use
Makefiles. Often, developers in these situations are using the tools that come
with the software environment they are using. If its rails, they are going to be
using `bundle`, `rails`, and `rspec` commands.  With a Makefile, you will still
be using these commands, but the Makefile will act as a wrapper around commands.

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
you can start using Makefiles right away. It turns out that Makefiles are very
simple when we break them down.

The Makefile is a file, usually in the root of a project, with the name Makefile.

A Makefile is made up of `rules`. A `rule` contains a `target`,
`prerequisites`, and `commands` which form a `recipe`.

    target_1: prerequisite_1 ... prerequisite_n
        command_1
        ...
        command_n
        
#### Target

The target is the thing you want to do (run a test, build code, drop a database, etc).

#### Prerequisite

Prerequisites are the rules needed to run before the recipe can run. For
example, imagine checking out a new ruby project and executing `bundle exec
rspec`; you will probably encounter an error about needing to run `bundle`
first! So, running `bundle` is a *prerequisit* of running rspec tests.

If you are thinking "oh, but I don't want to run bundle *every* time, don't
worry. Makefiles can determine if a prerequisite needs to be run or not. We'll
get to that.

#### Command

A command is simply run the shell (`sh` by default). If your target is
`test`, the command might be `bundle exec rspec`.

#### A dead simple example

    file_1: 
        touch file_1

- The target is `file_1`.
- There are no prerequisites.
- The command `touch file_1` produces `file_1`.

In a Makefile, it would be executed with `make file_1`.

#### A dead simple walkthrough

Let's add another target to the dead simple example.

    file_2: file_1
        touch file_2
        
- The target is `file_2`
- The prerequisite is `file_1`
- The command is `touch file_2`
        
        
At this point, I strongly recommend you follow along with your own makefile. You
will learn by doing. Create a makefile so that it looks like this:

    file_1:
        touch file_1

    file_2:
        touch file_2

And *be sure to use tabs to indent the commands*. This is a requirement that
trips up every person new to Make. If you do not use tabs, you will receive an
error that looks like this `Makefile:5: *** missing separator.  Stop.`

Now, if we run `make file_2`, it will first check for the target `file_1`, and
if that target does not exist, it will run the command to fulfill `file_1`.

    $ make file_2
    touch file_1
    touch file_2

If we subsequently run `make file_2`, we will see a message like this `make:
'file_2' is up to date.` Make is telling us it doesn't have to do anything
because `file_2` already exists.

    $ make file_2
    make: `file_2' is up to date.

Let's `rm file_2`, and then we see that `make file_2` will `touch file_2` but it
will not `touch file_1`.

    $ rm file_2
    $ make file_2
    touch file_2
    
Can you predict what happens if we `make file_2` at this point? If you are
thinking it will say `up to date` again, you are getting it!

    $ make file_2
    make: `file_2' is up to date.
    
Okay, so what will happen if we `touch file_1` and subsequently `make file_2`?

    $ make file_2
    touch file_2
    
Let's explore what is going on here.

Okay, quick tangent here. When we touch a file, what happens? If the file
doesn't exist, it creates that file; but what if that file already exists?
    
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
    $ ls -ahl
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:13 file_1
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 07:13 file_2
    $ make file_2
    make: `file_2' is up to date.
    
Do you see what's happening here? If the timestamp of the prerequisite is _more
recent_ than the timestamp of the current target, then the command for the
current target will run. This is how Make determines if the command of a
target should be run.

#### I Can't Get No Preqrequisite Satisfaction

We have looked into the some of the mechanics of the Make operations, and the
syntax of the Makefile, but how does this all work together, and what is the
_point_ of all this anyways? If it hasn't clicked yet, _that's okay_; we are
going to get there, I promise.

It will be helpful for a moment to think of a Makefile target as a tree, where
each node represents a target, and an branch represents a target's relationship to
its prerequisites.

    file_3 -- file_1
           \- file_2

Here we have three targets: `file_1`, `file_2`, and `file_3`. `file_3`
has prerequisites `file_2` and `file_1`, and since these are both
leaves, they do not have other prerequisites.

Represented in a makefile, it could look like this:

    file_1: 
        touch file_1
      
    file_2: 
        touch file_2
        
    file_3: file_1 file_2
        touch file_3
        
So, we are thinking of a target in the Makefile as representing a tree of
targets, where the target is the root, and the children of a node are the
prerequisites of that node. If the prerequisite of a node isn't
_satisfied_ (we'll get into what that means exactly), `make` will travel the
graph until it finds a node that _is_ satisfied. Once it finds that satisfied
prerequisite, it will reverse the path it just took to get to the satisfied
prerequisite, and for each node in this path, it will execute the target (which
itself could have it's own other prerequisites).

Let's look at a slightly more complex tree.

    file_6 -- file_5 -- file_4
                     \- file_3 -- file_2
                               \- file_1
                               
which corresponds to the following Makefile

    file_1:
        touch file_1
        
    file_2: 
        touch file_2
        
    file_3: file_2 file_1
        touch file_3
        
    file_4:
        touch file_4
        
    file_5: file_4 file_3
        touch file_5
        
    file_6: file_5
        touch file_6
        
Let's say the output of your `ls -ahl` is the following:
    
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 10:52 file_1
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 10:52 file_2
    -rw-r--r--   1 ben.brodie  staff     0B Aug  9 10:52 file_3
    
And we run

    make file_6
    
`make` now will traverse the tree, pushing each child onto a stack
recursively. Then, it will pop each node off the stack and check if it is
satisfied. If it is not satisfied, it will run the command for that node.

    stack.push(file_6) -> |file_6|
    stack.push(file_5) -> |file_5, file_6|
    stack.push(file_4) -> |file_4, file_5, file_6|
    stack.push(file_3) -> |file_3, file_4, file_5, file_6|
    stack.push(file_2) -> |file_2, file_3, file_4, file_5, file_6|
    stack.push(file_1) -> |file_1, file_2, file_3, file_4, file_5, file_6|
    
    stack.pop() -> file_1 <- |file_2, file_3, file_4, file_5, file_6|
    
Is `file_1` satisfied? It is a leaf and it exists, so **Yes**.

    stack.pop() -> file_2 <- |file_3, file_4, file_5, file_6|
    
Is `file_2` satisfied? It is a leaf and it exists, so **Yes**.

    stack.pop() -> file_3 <- |file_4, file_5, file_6|
    
Is `file_3` satisfied? `file_3` exists. It's children are `file_2` and `file_3`,
_and_ their timestamps are _older than_ the timestamp of `file_3`, so **Yes**.

    stack.pop() -> file_4 <- |file_5, file_6|
    
Is `file_4` satisfied? It does not exist so **No**. Run the command.

    touch file_4
    
    stack.pop() -> file_5 <- |file_6|
    
Is `file_5` satisfied? It does not exist so **No**. Run the command.

    touch file_5
    
    stack.pop -> file_6 <- | |
    
Is `file_6` satisfied? It does not exist so **No**. Run the command.

    touch file_6
    
We haven't come up with a formal definition of _satisfaction_, but now we
can. We know that for a target to be satisfied it must (1) exist and (2) the
target's timestamp must be newer than the timestamp of it's prerequisites. We
also know from this exercise that the entire tree is traversed, if _any_
prerequisite in the tree is not satisfied, _then the target of that prerequisite
is also not satisfied_. Therefore, (3) the prerequisite targets must be satisfied.

### Satisfaction Summary

This section is just a summary of what we just arrived at. The properties of
satisfaction for a target. 

1. The target must exist.
2. The target's timestamp must be newer than the timestamp of the target's 
   prerequisites.
3. The prerequisite targets must be satisfied.

### Make is about files

So far, we have been talking about files. The first property requires that the
"target exists" - a target's existence is determined by a file of the same name
existing. The timestamp requirement, that a timestamp must be newer than the
timestamp of the prerequisites, is also only meaningful when the target name has
a one-to-one correspondence with files.

This is the point at which one realizes what `make` is all about, and without
some further prodding, it is easy to mistakenly believe that it may *not* be relevant
to *your* set of problems or *your* language tools - but this is the naive fog
of mis-perceptions clouding judgment - we will get to the good stuff soon enough.

Make is about files. Files are the primitives of how make operates, because
files allow us to keep track of *state*. If the prerequisite of a target is
satisfied, *make won't run the prerequisites*. If some prerequisites along the
line are satisfied, *make will only run the prerequisites that are not
satisfied*.

This all comes down to that timestamp property - *the target's timestamp must be
newer than the timestamp of the target's prerequisites*. Keep in mind that the
third property makes this recursive, so it applies all the way down the tree of
prerequisites. 

Let's consider the implications of the timestamp property. If a prerequisite's
timestamp is newer than the target's timestamp, that means that the
prerequisite was generated some time _after_ the time the target was
generated. A prerequisite relationship exists because something about the target
*depends on* something about the prerequisite, therefore, if the prerequisite is
newer, then we must have to regenerate the target, otherwise the target as it
currently exists is outdated.

Time for an analogy. I'm booking a trip to Poland, and then flying to Tromsø,
Norway by way of a flight from Riga, Latvia. I have to plan the return flight from Tromsø
to Los Angeles, and the date at which I book that is dependent upon the date at
which I am flying into Norway from Riga. Every time I update the
date to fly to Tromso from Riga, I have to update the time I want to
fly back to Los Angeles from Tromso, otherwise I could be left with half a day
in Tromsø, or even end up with something impossible, like flying back
to Los Angeles from Tromsø *before* landing in Tromsø.

Let's formulate this as a Makefile, where we have four trip legs we need to
coordinate.

1. Flight from Los Angeles to Krakáw, Poland
2. Drive from Krakáw, Poland to Riga
3. Fly from Riga to Tromsø
4. Fly from Tromsø to Los Angeles

        schedule_flight_to_krakow: 
            echo $(krakow_date) > schedule_flight_to_krakow

        schedule_drive_to_riga: schedule_flight_to_krakow
            echo $(riga_date) > schedule_drive_to_riga

        schedule_flight_to_tromso: schedule_drive_to_riga
            echo $(tromso_date) > schedule_flight_to_tromso

        schedule_flight_to_los_angeles: schedule_flight_to_tromso
            echo $(los_angeles_date) > schedule_flight_to_los_angeles

Here I have introduced a new piece of syntax in make files - arguments. A word
surround with a `$(...)` will be replaced by the string specified on the command
line for that argument. For example, `$(arg_1)` will be replaced by `file_1` in
either of these invocations of `make`: `arg_1=file_1 make file` or `make file
arg_1=file_1`. Simple, right? Yes, it is.

So, to schedule the flight to Krakáw, we invoke `make` as `make
schedule_flight_to_krakow krakow_date=08/01/2019` 

Let's see what it produced.

    $ cat schedule_flight_to_krakow
    10/01/2019
    
It would be easier to simply pass all of the dates and have `make` take care of
creating all of the files. By default, `make` will run the first target in the
file, and idiomatically we will call this target `all`.

    all: schedule_flight_to_los_angeles
    
Now we can invoke this with or without `all`

    $ make krakow_date=10/01/2019 \
           riga_date=10/15/2019 \
           tromso_date=10/20/2019 \
           los_angeles_date=10/23/2019
      echo 10/01/2019 > schedule_flight_to_krakow
      echo 10/15/2019 > schedule_drive_to_riga
      echo 10/20/2019 > schedule_flight_to_tromso
      echo 10/23/2019 > schedule_flight_to_los_angeles
      
#### Error handling

Let's add some error handling so that we know which flight dates are required
when we run make.

We can use `sh` itself to handle errors, in this case missing arguments.

    all: schedule_flight_to_los_angeles

    schedule_flight_to_krakow:
        @if [ -z "$(krakow_date)" ]; then \
            echo "You must set krakow_date"; exit 1; fi
        echo $(krakow_date) > schedule_flight_to_krakow

    schedule_drive_to_riga: schedule_flight_to_krakow
        @if [ -z "$(riga_date)" ]; then \
            echo "You must set riga_date"; exit 1; fi
        echo $(riga_date) > schedule_drive_to_riga

    schedule_flight_to_tromso: schedule_drive_to_riga
        @if [ -z "$(tromso_date)" ]; then \
            echo "You must set tromso_date"; exit 1; fi
        echo $(tromso_date) > schedule_flight_to_tromso

    schedule_flight_to_los_angeles: schedule_flight_to_tromso
        @if [ -z "$(los_angeles_date)" ]; then \
            echo "You must set los_angeles_date"; exit 1; fi
        echo $(los_angeles_date) > schedule_flight_to_los_angeles
        
The `@` simply specifies that `make` will not echo the command, which for error
checking would be just noise.

Now if we run from a clean state, `make` will inform us of any necessary
arguments that are necessary, and fail. Here we have left out `riga_date`.

    $ make krakow_date=10/01/2019 \
           tromso_date=10/20/2019 \
           los_angeles_date=10/23/2019
      echo 10/01/2019 > schedule_flight_to_krakow
      You must set riga_date
      make: *** [schedule_drive_to_riga] Error 1

Let's set the `riga_date`.

    $ make riga_date=10/15/2019 \
            tromso_date=10/20/2019 \
            los_angeles_date=10/23/2019
      echo 10/15/2019 > schedule_drive_to_riga
      echo 10/20/2019 > schedule_flight_to_tromso
      echo 10/23/2019 > schedule_flight_to_los_angeles

Say we now want to reschedule the flight to Riga, Tromsø, and Los Angeles - we
won't be able to since we have already schedule the flight to Krakow.

    $ make riga_date=10/16/2019 \
           tromso_date=10/21/2019 \
           los_angeles_date=10/24/2019
      make: Nothing to be done for `all'.
      
#### Prerequisites

`make` won't allow us to reschedule once we have scheduled something.

    $ make schedule_drive_to_riga riga_date=10/16/2019 
    make: `schedule_drive_to_riga' is up to date.
    
But, for now, we can manually `rm` the file.

    $ rm schedule_drive_to_riga
    
And then schedule it.

    $ make schedule_drive_to_riga riga_date=10/16/2019 
    
Let's try to reschedule the flight to Los Angeles in the same manner.

    $ rm schedule_flight_to_los_angeles
    $ make schedule_flight_to_los_angeles los_angeles_date=10/24/2019
      You must set tromso_date
      make: *** [schedule_flight_to_tromso] Error 1
      
`Make` detects that our `schedule_flight_to_tromso` prerequisite is not
satisfied because the timestamp of `schedule_flight_to_riga` is _newer_ than the
timestamp of `schedule_flight_to_trompso`, therefore it also must be updated!
So, let's do that.

    $ make schedule_flight_to_los_angeles tromso_date=10/22/2019 los_angeles_date=10/24/2019
      echo 10/22/2019 > schedule_flight_to_tromso
      echo 10/24/2019 > schedule_flight_to_los_angeles

### Make is not about files

So far, we have seen that the targets of a Makefile truly represent
_files_. But, this seems limiting. For example, what if we want to make a
`reschedule` target?

Previously, we had to manually `rm` the file to reschedule it. A `reschedule`
target should allow us to run something like `make
reschedule_flight_to_los_angeles los_angeles_date=10/24/2019`. 

It turns out that we can do this. If we consider what it means to reschedule, it
seems there is no circumstance where we want to block the reschedule (i.e., we
are actively rescheduling, therefore we _intend_ to schedule when the date is
already set). 

How about something as simple as this:
    
    reschedule_flight_to_los_angeles: schedule_flight_to_los_angeles
        @if [ -z "$(los_angeles_date)" ]; then \
            echo "You must set los_angeles_date"; exit 1; fi
            echo $(los_angeles_date) > schedule_flight_to_los_angeles
            
This looks familiar, as it is _the same recipe_ as
`schedule_flight_to_los_angeles`. Yet, it behaves differently. We can run it as
many times as we want, and it won't complain.

    $ make reschedule_flight_to_los_angeles los_angeles_date=10/25/2019
      echo 10/25/2019 > schedule_flight_to_los_angeles
    $ test$ make reschedule_flight_to_los_angeles los_angeles_date=10/26/2019
      echo 10/26/2019 > schedule_flight_to_los_angeles
    $ test$ make reschedule_flight_to_los_angeles los_angeles_date=10/27/2019
      echo 10/27/2019 > schedule_flight_to_los_angeles
      
The essential difference is that the file being produced is _not_ the same name
as the target. Because do not create a file with the same name as the
target, from Make sees this target as _never up to date_.

Earlier we implemented the `all` target - this target is also independent of a
cooresponding file. 

But, what if some other process _does_ result in a file name clashing with a
target?

It is probably a good idea to add a `clean` task to start our schedule fresh, as
if we had never scheduled anything. 

    clean:
        rm schedule*
        
This will remove all files that begin with "schedule" in their name, effectively
forgetting that we had ever scheduled anything. 

It is not inconceivable, however, that some other process might result in a file
named `clean`, resulting in a confusing bug.

    $ touch clean
    $ make clean
      make: `clean' is up to date.
      
`Make` has a special target called `.PHONY`, and any prerequisits of this target
are always determined to be out-of-date, and will be always be run. 

    .PHONY: clean

And now when we run clean, it does not check if the file exists.

    $ touch clean
    $ make clean
      rm schedule*
      rm: schedule*: No such file or directory
      make: *** [clean] Error 1
      
Notice, however, that this results in an error, because we have already cleaned
out the "schedule" files. Ideally, this should not result in an error; we expect
success upon removing the files _or_ if the files are already moved, and, if we
can prevent this from resulting in error, then the `clean` target has the
useful property of [idempotency](https://en.wikipedia.org/wiki/Idempotence).

We can tell `make` to ignore errors with a `-` prepended to the recipe.

    clean:
        -rm schedule*
        
Now when we run `clean`, the error will be ignored.

    $ make clean
    rm schedule*
    rm: schedule*: No such file or directory
    make: [clean] Error 1 (ignored)
    
An ignored error will still report the error, but it will not halt the Make
process.

Our final, albeit highly contrived, Makefile looks as follows:


    .PHONY: all clean reschedule_flight_to_los_angeles

    all: schedule_flight_to_los_angeles

    schedule_flight_to_krakow:
        @if [ -z "$(krakow_date)" ]; then \
            echo "You must set krakow_date"; exit 1; fi
            echo $(krakow_date) > schedule_flight_to_krakow

    schedule_drive_to_riga: schedule_flight_to_krakow
        @if [ -z "$(riga_date)" ]; then \
            echo "You must set riga_date"; exit 1; fi
            echo $(riga_date) > schedule_drive_to_riga

    schedule_flight_to_tromso: schedule_drive_to_riga
        @if [ -z "$(tromso_date)" ]; then \
            echo "You must set tromso_date"; exit 1; fi
            echo $(tromso_date) > schedule_flight_to_tromso

    schedule_flight_to_los_angeles: schedule_flight_to_tromso
        @if [ -z "$(los_angeles_date)" ]; then \
            echo "You must set los_angeles_date"; exit 1; fi
            echo $(los_angeles_date) > schedule_flight_to_los_angeles

    reschedule_flight_to_los_angeles: schedule_flight_to_los_angeles
        @if [ -z "$(los_angeles_date)" ]; then \
            echo "You must set los_angeles_date"; exit 1; fi
            echo $(los_angeles_date) > schedule_flight_to_los_angeles

    clean:
        -rm schedule*

### Making it fit with Ruby (or any other language)

I've given an overview of Make, along with a contrived example. Now I would like
to illustrate how this can be used as a practical tool in your development workflow.

I think that many developers feel that their build tool that comes with their
language is all they need - just run `rspec test`, `rails server`, or `npm
install` to get some task done.

However, many of these tools don't make use of dependency relationships, and
often what comes out of the box can't know what those dependency relationships
are. For example, I worked on a Rails project, where Javascript had to be
compiled by Webpacker if there were any changes to the front-end layer. The
integration tests in our test suite exercised the web front-end, and if
Webpacker was not run when a change was introduced, tests could fail, leading to
incorrect conclusions about the state of the code, and a lot of wasted time
until the developer realized "Oh, I forgot to run Webpacker!". 

Additionally, if you were running the server live on your machine, there was a
Webpacker process watching for live code changes and recompiling the Javascript
when a change happened - so in this case, if the developer ran the integration
tests, the tests _would_ accurately reflect the current state of the code.

The success of the test suite should not rely on an assumption that _another_
process is running and watching code. First, if that process is not running,
then the tests can't pass. Second, this implies that the prerequisites for that
test suite are not captured in the test command, which can lead to issues on a
CI server, a clean checkout of code, or a new developer setting up. A successful
test suite should never rely on the state of externalities. This leads to
inconsistent behavior.

I don't suggest that its wrong to have a process watching code and recompiling,
that is perfectly fine for the goal of having a self-updating live site for
experimentation - but that is simply a different use case than running a test
suite, so don't mix them.

One could also simply have a script that runs all of the prerequisites before
running a test, but that script wouldn't have a system of keeping track of what
needs to be run and what doesn't. If the Javascript is already compiled, then it
would waste time to wait for it to compile each time you run a test. Make
determines if the Javascript needs to be compiled due to changes.

One could use Rake to capture the prerequisites for the test run. This would
be a perfectly acceptable approach. However, there is likely a reason that I
haven't seen this done; Rake is complex, coupled to the project in ways that
don't generalize easily, and the tasks that come out of the box are written to
exercise the framework (rails).

Rake, although named to suggest it is Ruby Make, is neither a replacement for
make, nor does it conflict with make. Instead, I see Rake as being a
useful tool for Ruby and Framework specific tasks, like database migrations,
while Make fits in as the general purpose glue to connect all of these
commands and dependencies. It is simpler to write a command in Make and
declare it's dependencies than doing so in Rake, and the Makefile can
actually leverage the Rake tasks that already exist, by calling `rake
some_task` in the recipe.

Furthermore, Make is language agnostic, so it fits nicely into _any_ project. A
developer can simply look at the Makefile in a given project, and they have list
of commands that exercise that project, even if they are unfamiliar with the
language or framework.

I want to reiterate that Make _does not replace_ a given build tool, it simply
_wraps_ around those tools to make doing higher level things simpler and
consistent.

### An Actual Example

Even a simple project can benefit greatly from a Makefile. A few months ago, I
was asked to put together a small project for interview test. This project
involved a backend server, and a front-end component in React. As I ran various
commands and patterns emerged, I added them to the Makefile. Because modern
build tools sometimes have side effects that are not captured as a file, such as
`bundle exec rake db:setup`, which sets up the database, I devised a pattern for
the Makefile to capture that these tasks had occurred, so they would not run if
not needed.


    .PHONY: serve live-reload db-reset db-setup db-migrate init deps compile bundle yarn clean

    serve: init deps compile db-setup db-migrate
        rails server

    live-reload: yarn
        ./bin/webpack-dev-server --host 127.0.0.1

    db-reset:
        bundle exec rake db:reset

    db-setup: .make.db-setup

    db-migrate: .make.db-migrate

    init: .make.init

    deps: bundle yarn

    compile: .make.webpacker

    bundle: .make.bundle

    yarn: .make.yarn

    clean:
        rm .make.*

    .make.webpacker: $(shell find app/javascript -type f)
        ./bin/webpack
        touch .make.webpacker

    .make.db-setup: .make.bundle
        bundle exec rake db:setup
        touch .make.db-setup

    .make.db-migrate: .make.bundle $(shell find db/migrate -type f)
        bundle exec rails db:migrate
        touch .make.db-migrate

    .make.bundle: Gemfile
        bundle
        touch .make.bundle

    .make.yarn: package.json
        yarn
        touch .make.yarn

    .make.init:
        gem install bundler
        touch .make.init
        
Take a minutes to look this over and understand it. Our main entry-point
here, and what will run by default on an invocation of make without arguments,
is `serve`.

#### init

Let's go through the prerequisites of the `serve` target. First, there is an
`init` prerequisite. This prerequisite ensures that bundler is installed (but
could also be used for installing requirements with homebrew, for
example). `init` has a prerequisite `.make.init` which first runs `gem install
bundler` and then creates the file `.make.init`. Because `.make.init` is the
name of the file it creates, it will never run again (unless the file is
deleted). This is a simple way of capturing side effects as a file to indicate
that the task has already been run. 

#### deps

`deps` ensures that all dependencies have been installed to the project and if
any new versions have been specified, or dependencies have been added or removed
from the project, the dependencies will be updated. `deps` has two
prerequisites - `bundle` and `yarn`. 

#### bundle

`bundle` runs `bundle` to update the Ruby dependencies of the project _if and
only if_ the `Gemfile` file has been updated. We see this in the `.make.bundle`
target which has a prerequisite of `Gemfile`, which is just that file. After
`bundle` has successfully run, the file `.make.bundle` is created. Whenever the
timestamp of `Gemfile` is _newer_ than the timestamp of `.make.bundle`, which is
precisely what would happen in the case of added, removing, and changing the
version of a dependency, the task will be run again! Otherwise, it won't do anything. 

#### yarn

`yarn` does the same thing as the `bundle` target, except that this task is
dependent on the `package.json` file, and runs the `yarn` command.

#### compile

`compile` runs `webpack` to compile the Javascript. Importantly, it only does
this if any of the Javascript files have been updated. It does this by setting
it's prerequisites as all of the Javascript files! If _any one_ of them has a
timestamp newer than the `.make.webpacker` file, then it will run
`webpack`. This target also introduces us to two new concepts in the makefile:
the `shell` function, and dynamically generated prerequisites. As you can see,
the ability to dynamically generate prerequisites is very powerful. The `shell`
function simply runs the command in the shell, and returns what the function
returns, in this case a list of all files in the `app/javascript` directory.

#### db-setup

`db-setup` runs `bundle exec rake db:setup` if it hasn't been run yet. If
`bundle` hasn't been installed first, it will install it.

#### db-migrate

`db-migrate` is a really nifty target to have in a rails project. Before I
figured this one out, quite often I would switch to another branch, or pull new
code, and then my database would be out of sync with the migrations. This target
automates this problem away. Never again will you see a message about needing to
run migrations! Like `compile`, `db-migrate` uses the `shell` function to
dynamically generate a list of prerequisites that are all migrations in the
project. If any of them are newer than `.make.db-migrate`, it runs 
`bundle exec rails db:migrate`. If `bundle` has yet to be installed, it will
install it first.

#### serve

Once all of those are done, it's time to serve the application - `rails server`
does the trick.

#### Adding a new target

There is something missing here... no test target! But, notice how simple it
would be to add a `test` target. We already have all of the required target
prerequisites defined. They are _the same_ as those for the `serve` target.

    test: init deps compile db-setup db-migrate
        rspec test
        
Developing a Makefile along with developing code is quite natural, and once a
solid foundation is laid, it is often this simple to define new targets. 

### Decoupled Freedom

Because Make is a general purpose tool that is decoupled from languages and
frameworks, it becomes incredibly freeing once Make becomes part of the workflow.

For example, I am working on a project at the moment that requires a database to
be loaded in order to run the server. I decided that it would be less coupled to
the system if I simply spun up a database with docker instead of relying on a
database actually running as a service on my machine. 

Often, using docker in a project can become problematic, because there is no
tool in place to manage the docker instances. Sometimes docker is running, and
all goes well, sometimes it isn't running, requiring the developer to remember
one of those confusing docker commands (is it create, run, exec, or
start?). What happens if the database on the docker image gets trashed? Now you
need to remember another set of commands to reset the database.

Makefiles allow the developer to create a workflow with docker that isn't
confusing, and remains consistent and predictable.

I'm working on a project right now where I am attempting to do this. Using a
Makefile allows me to start mysql as a dependency when I run the server (or,
when I need it for a test). I have modified it below into an example.

    ...
    run: build mysql-start
        ./start-myapp
    
    mysql-create: 
        @docker container ls -a | grep my_app_mysql || \
          (docker create -p 3306:3306 \
            --name my_app_mysql \
            -v $$(pwd)/mysql/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
            -v $$(pwd)/mysql/mysql-keyring:/var/lib/mysql-keyring \
            -e MYSQL_ROOT_PASSWORD=password \
            mysql:8.0.18 \
            --early-plugin-load=keyring_file.so \
            --lower-case-table-names=1

    mysql-start: mysql-create
        docker start my_app_mysql
        while ! docker exec my_app_mysql -h 127.0.0.1 -ppassword -e \
        "\q" 2> /dev/null; do echo "Waiting for MySQL..." && sleep 1; done
        
    mysql-stop:
        docker stop my_app_mysql
        
    mysql-clean:
        docker rm my_app_mysql
        
    mysql-shell:
        docker exec -it my_app_mysql -h 127.0.0.1 -ppassword
        
    mysql-logs
        docker logs my_app_mysql
    ...
    
As you can see, our recipes can become quite complex once we have some
requirements. Here, we have schema that has encryption enabled, so requires some
configuration around that. Running these manually would be unproductive. `mysql-create`
_only_ creates the container if the container doesn't already exist. I am using
`||` to accomplish this. Furthermore, in `mysql-start`, `docker start` is
idempotent, so if container is started, it will work just fine. The `while` loop
checks that a process can connect to `mysql`, and if it cannot, it waits one
second and attempts to check again. This is necessary as the `mysql` database
process is not always available immediately, so we need to wait until it is up
to connect to it.

Without a Makefile in place, we simply would not have the freedom to get docker
into our development workflow in a consistent manner. At best, we would have
some scripts for stopping and starting the container, but these would have to be
run manually, inevitably leading to accidently running the server without the
database up, and mysterious requirements that an on-boarding developer may not
be aware of.

### How to develop a Makefile

They key to successfully writing a Makefile is to just write down the
commands you need at the moment. Ran a new command? Put it in the
Makefile. Over time, the Makefile will grow to include even those rare
commands you rarely run and can't remember what they were. Patters with emerge,
and these will help guide the prerequisites that may otherwise not be obvious.

It is essential to not attempt to define all of the commands up front. Updating
and refining the Makefile is _part of_ the development workflow itself; things
change, and so does the Makefile over time. Because the Makefile is general and
flexible, these changes are usually quite simple to implement. Additionally,
because developers will be running makefiles _all the time_, they stay up to
date, unlike documentation. If it doesn't work, it will require an immediate fix.

### Go for it

I hope that I have clarified Makefiles and perhaps convinced you of their
power. Just go ahead and try it in your current project, and see what it can do
for. 
