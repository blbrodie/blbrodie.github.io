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

Feeling a bit like you are on an island? We have looked into the some of the
mechanics of the `make` operations, and the syntax of the `Makefile`, but how
does this all work together, and what is the _point_ of all this anyways? If it
hasn't clicked yet, _that's okay_; we are going to get there, I promise.

It will be helpful for a moment to think of a Makefile target as a tree,
where each node represents a target, and an edge represents a
target's relationship to it's prerequisites.

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
        
Following? If not, that's okay, just reread this section - it's a key
concept.

So, we are thinking of a target in the Makefile as representing a tree of
targets, where the target is the root, and the children of a node are the
prerequisites of that node. If the prerequisite of a node isn't
_satisfied_ (we'll get into what that means exactly), `make` will travel down the
tree until it finds a node that _is_ satisfied. Once it finds that satisfied
prerequisite, it will reverse the path it just took to get to the satisfied
prerequisite, and for each node in this path, it will execute the target (which
itself could have it's own other prerequisites).

Let's look at a slightly more complex tree.

    file_6 -- file_5 -- file_4
                     \- file_3 -- file_2
                               \- file_1
                               
which corresponds to the following `Makefile`

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
    
Is `file_3` satisfied? `file_3` exists. It's children are `file_2` and `file_3`, _and_ their
timestamps are _older than_ the timestamp of `file_3`, so **Yes**.

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
can. As we saw earlier, we know two things must hold for satisfaction of a
target:
1. The target must exist.
2. The target's timestamp must be newer than the timestamp of it's
   prerequisites.
                               
We also know from this exercise that the entire tree is traversed, if _any_
prerequisite in the tree is not satisfied, _then the target of that prerequisite
is also not satisfied_. This gives us a third property:
1. The target must exist.
2. The target's timestamp must be newer than the timestamp of it's
   prerequisites.
3. The prerequisite targets must be satisfied.

### Satisfaction Summary
This section is just a summary of what we just arrived at. The properties of
satisfaction for a target. 

1. The target must exist.
2. The target's timestamp must be newer than the timestamp of the target's 
   prerequisites.
3. The prerequisite targets must be satisfied.

### Make is about files

So far, we have been implicitly only talking about files. The first property
requires that the "target exists" - a target's existence is determined by a file
of the same name existing. The timestamp requirement, that a timestamp must be
newer than the timestamp of the prerequisites, is also only meaningful when the
target name has a one-to-one correspondence with files. 

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
which my girlfriend and I flying into Norway from Riga. Every time we update the
date we want to fly to Tromso from Riga, we have to update the time we want to
fly back to Los Angeles from Tromso, otherwise we could be left with half a day
in Tromsø, or even end up with something physically impossible, like flying back
to Los Angeles from Tromsø *before* we land in Tromsø.

Let's formulate this as Makefile rules, where we have four trip legs we need to coordinate.

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

### Makefiles are not about files

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
as the target. In fact, we simply do not create a file with the same name as the
target, therefore from `make`'s point of view, the target is _never up to date_.


### Making Bread Analogy
                    
### Making it fit with Ruby (or any other language)
- Not in opposition to rake, rather complementary

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

### Make vs Rake vs ...
This is the wrong question to be asking. These tools are not diametrically opposed, rather, work together quite effectively.
    



