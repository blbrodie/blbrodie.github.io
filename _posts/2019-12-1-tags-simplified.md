---
layout: post
title: TAGS, simplified
tags: [emacs, vim, ctags, tags, ctags, exuberantctags, programming]
---

Similar to my previous post on [Makefiles]({% post_url
2019-11-17-the-language-agnostic-all-purpose-incredible-makefile %}), where I
claim that Makefiles are the entry point for a project's commands, here I claim
that tags are the entry point to navigating through a project's code. For
example, if you use Vim or Emacs with evil-mode, with your cursor on a function
call, `Ctrl-]` will jump you to the function definition, while `Ctrl-T` will
jump you back to where you came from!

Yet, these simple, but essential, navigation commands won't work out of the
box. First, you need to generate a tags file. The benefit is that *any* editor
that supports tags can navigate through your code automatically! In this post I
focus on Vim and Emacs, but your editor of choice is just a Google search away.

If you have a tags file (named `TAGS` or `tags`) at the root of your project,
Emacs will find and load this file when running a tags related command (e.g.,
`Ctrl-]`). Vim probably has a similarly simple mechanism. 

So, we need to generate a TAGS file. We start with a **WTF**.

### WTF

So, how do you generate a tags file? I have discovered an incredibly simple
approach that should work across the board for any git-based project. This
approach is valuable to know, as there is a whole lot of muddy water in the area
of tag generation, with conflicting tools, and overly complex tags commands. I
believe that the reason more people aren't utilizing tags is that the resulting
Google searches are misleading and intimidating; who wants to have to write a
command specifically tailored to their project, and what about projects that
have multiple languages, as many do today? 

Further complicating matters is an array of different tags generation tools,
that sometime have conflicting names! The `ctags` tool that comes pre-installed
on macOS *will not work*, for example. Emacs installs it's own tags tool
called `etags` *or* `ctags` that, confusingly, *will also
not work*. When I say "will also not work", I mean they won't work in a general
way that we would like, a command we can apply across the board, independent of
your OS and your editor (or as close to that as possible). There is another
`ctags` tool, which, confusingly, is referred to as "ExuberantCtags", and this
tool *does* work, but it is no longer maintained; it is now maintained as
[UniversalCtags](https://ctags.io). And don't get me started on `ggtags`,
confusingly referred to as simply [GNU
Global](https://www.gnu.org/software/global), which has an Emacs mode that is
used by Emacs's Projectile Mode (`projectile-regenerate-tags`) but seems to only
result in endlessly hanging Emacs, and has two different "backends" - pygments
(which is actually a "generic syntax highlighter"!) and ctags (Which ctags
again? There are four different ones on the last count.), and on what basis
should someone choose between the Python "generic syntax highlighter" and ctags?

Navigating all of this makes it feel as if getting a tagging system in place is
some sort of a dark art. At best, you find something that works sometimes for
some projects, and otherwise crashes; good luck getting it to work on *another*
machine, or helping your teammate get theirs working.  (Uhhh, which ctags is
installed again?).

So, we need a simple solution. 

### A Simple Solution 

Luckily, you don't need to navigate through all that mud to find a simple
solution, because I'm going to tell you my solution.

Whatever system you are on, install ExuberantCtags (or UniversalCtags, they
should be the same, I think!). 

On macOS, this is what you get with `brew install ctags`. This will replace any
other (wrong) ctags on your system. On other systems, just make sure you are
installing the ExuberantCtags version.

To check if you have a working version of ctags, run (in a project): 

    ctags -R .
    
If you don't get an error, I *think* you have a good version.

ExuberantCtags knows a whole bunch of languages out of the box. It identifies
languages by the file extension. This means that you can run it on files of
different languages and it will generate tags for all of them. If you use a
language that it doesn't know out of the box, such as Elixir, you can add it to
your `~/.ctags` [file](https://github.com/mmorearty/elixir-ctags).

The command we just tested, `ctags -R .`, recursively runs against all the
files in your project. This is simple, and is sometimes presented as a
solution. However, this isn't a full solution, yet.

First, this command generates a vim compatible tags files, but if you want an
Emacs compatible file, you need to use the `-e` flag.

    vim: ctags -R .
    emacs: ctags -e -R .
    
This is pretty simple. However, if you are working in a project that imports
dependencies into the project (such as projects which use node) or generates
compiled files, ctags might choke on the sheer volume of files it has to work
through. 

Luckily, if you are using a git version-controlled project, it is very simple to
filter out all ignored files (files which are not part of version control). It
turns out that the only files you would need tags for are those which are
version controlled. 

    git ls-files
    
This command lists all files that *are* version controlled by git. So, if we can
operate ctags on only those files, we will save a lot of computation
time. Furthermore, this is generic; it will work on any project controlled by
git, so we don't have to write a whole bunch of project specific includes or
excludes. Simple.

Ctags has a `-L` flag:

    
    -L <file>
        A list of source file names are read from the specified file.
        If specified as "-", then standard input is read.
        
So, we could use the result of `git ls-files` in a two-step process:

    git ls-files > ls-files
    ctags -e -R -L ls-files

But if we specify the flag as `-L-`, ctags will read this list from standard
input. This means we can pipe the list to ctags:

    git ls-files | ctags -e -R -L-
    
And because this is generic, and recursive, I want to avoid problems that could
be caused by symbolic links. We can use `--links=no` to avoid following these
links; but if your project uses symbolic links, you could always enable it.


    git ls-files | ctags -e -R --links=no -L-
    
I have an alias in my `~/.bashrc` for this:

    alias tags=git ls-files | ctags -e -R --links=no -L-
    
This can really be used anywhere though. Using it in a Makefile and/or
as a git hook is a great ideas. You can also add a function to your editor to call it
with a keybinding. So far, I just call it directly in the command line. 

### TL;DR

* Install ExuberantCtags (`brew install ctags`, if macOS)
* `git ls-files | ctags -e -R --links=no -L-` (emacs)
* `git ls-files | ctags -R --links=no -L-` (vim)
