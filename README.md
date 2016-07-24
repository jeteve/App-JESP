# NAME

App::JESP - Just Enough SQL Patches

# SYNOPSIS

Use the command line utility:

    jesp --home path/to/jesphome

Or use from your own program (in Perl):

    my $jesp = App::JESP->new({ home => 'path/to/jesphome',
                                dsn => ...,
                                username => ...,
                                password => ...
                              });

    $jsep->install();
    $jesp->deploy();

# CONFIGURATION

All JESP configuration must live in a JESP home directory.

This home directory must contain a plan.json file, containing the patching
plan for your DB. See plan.json section below for the format of this file.

## plan.json

This file MUST live in your JESP home directory. It has to contain
a json datastructure like this:

    {
      "patches": [
          { "id":"foobartable", "sql": "CREATE TABLE foobar(id INT PRIMARY KEY)"},
          { "id":"foobar_more", "file": "patches/morefoobar.sql" }
      ]
    }

Patches MUST have a unique ID in all the plan, and they can either
contain raw SQL (SQL key), or point to a file of your choice (in the JESP home)
itself containing the SQL.

# COMPATIBILITY

Compatibility of the meta-schema with SQLite, MySQL and PostgreSQL is guaranteed through automated testing.
To see which versions are actually tested, look at the CI build:
[https://travis-ci.org/jeteve/App-JESP/](https://travis-ci.org/jeteve/App-JESP/)

# MOTIVATIONS & DESIGN

Over the years as a developer, I have used at least three ways of managing SQL patches.
The ad-hoc way with a hand-rolled system which is painful to re-implement,
the [DBIx::Class::Migration](https://metacpan.org/pod/DBIx::Class::Migration) way which I didn't like at all, and more recently
[App::Sqitch](https://metacpan.org/pod/App::Sqitch) which I sort of like.

All these systems somehow just manage to do the job, but unless they are very complicated (there
are no limits to hand-rolled complications..) they all fail to provide a sensible
way for a team of developers to work on database schema changes at the same time.

So I decided the world needs yet another SQL patch management system that
does what my team and I really really want.

Here are some design principles this package is attempting to implement:

- Write your own SQL

    No funny SQL generated from code here. By nature, any ORM will always lag behind its
    target DBs' features. This means that counting on sofware to generate SQL statement from
    your ORM classes will always prevent you from truly using the full power of your DB of choice.

    With App::JESP, you have to write your own SQL for your DB, and this is a good thing.

- No version numbers

    App::JESP simply keep track of which ones of your named patches are applied to the DB.
    Your DB version is just that: The subset of patches that were applied to it. This participates
    in allowing several developers to work on different parts of the DB in parrallel.

- No fuss patch ordering

    The order in which patches are applied is important. But it is not important
    to the point of enforcing excatly the same order on every DB the patches are deployed to.
    App::JESP applies the named patches in the order it finds them in the plan, only taking
    into account the ones that have not been applied yet. This allows developer to work
    on their development DB and merge seemlessly patches from other developers.

- JSON Based

    This is the 21st century, and I feel like I shouldn't invent my own file format.
    This uses JSON like everything else.

- Simple but complex things allowed.

    You will find no complex feature in App::JESP, and we pledge to keep the meta schema
    simple, to allow for easy repairs if things go wrong.

- Programmable

    It's great to have a convenient command line tool to work and deploy patches, but maybe
    your development process, or your code layout is a bit different. If you use [App::JESP](https://metacpan.org/pod/App::JESP)
    from Perl, it should be easy to embed and run it seemlessly yourself.

- What about reverting?

    Your live DB is not the place to test your changes. Your DB at <My Software> Version N should
    be compatible with Code at <My Software> Version N-1. You are responsible for testing that.

    We'll probably implement reverting in the future, but for now we assume you
    know what you're doing when you patch your DB.

# METHODS

## install

Installs or upgrades the JESP meta tables in the database. This is idem potent.
Note that the JESP meta table(s) will be all prefixed by **$this-**prefix()>.

Returns true on success. Will die on error.

Usage:

    $this->install();

## deploy

Deploys the unapplied patches from the plan in the database and record
the new DB state in the meta schema. Dies if the meta schema is not installed (see install method).

Returns the number of patches applied.

Usage:

    print "Applied ".$this->deploy()." patches";

# DEVELOPMENT

<div>
    <a href="https://travis-ci.org/jeteve/App-JESP"><img src="https://travis-ci.org/jeteve/App-JESP.svg?branch=master"></a>
</div>

# COPYRIGHT

This software is released under the Artistic Licence by Jerome Eteve. Copyright 2016.
A copy of this licence is enclosed in this package.
