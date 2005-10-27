package DBIx::Admin::TableInfo;

# Name:
#	DBIx::Admin::TableInfo.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 2004 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;
no warnings 'redefine';

use Carp;

require 5.005_62;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DBIx::Admin::TableInfo ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '1.03';

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(	# Alphabetical order.
		_column_catalog	=> undef,
		_column_schema	=> undef,
		_dbh			=> '',
		_table_catalog	=> '',
		_table_schema	=> '',
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _info
	{
		my($self)		= @_;
		$$self{'_info'}	= {};
		my($table_sth)	= $$self{'_dbh'} -> table_info($$self{'_table_catalog'}, $$self{'_table_schema'}, '', 'TABLE');

		my($table_data, $table_name, $column_data, $column_name);

		while ($table_data = $table_sth -> fetchrow_hashref() )
		{
			$table_name						= $$table_data{'TABLE_NAME'};
			$$self{'_info'}{$table_name}	=
			{
				attributes	=> {},
				columns		=> {},
			};

			for (keys %$table_data)
			{
				next if (! defined($$table_data{$_}) );

				$$self{'_info'}{$table_name}{'attributes'}{$_} = $$table_data{$_};
			}

			my($column_sth)	= $$self{'_dbh'} -> column_info($$self{'_column_catalog'}, $$self{'_column_schema'}, $table_name, '%');

			while ($column_data = $column_sth -> fetchrow_hashref() )
			{
				$column_name											= $$column_data{'COLUMN_NAME'};
				$$self{'_info'}{$table_name}{'columns'}{$column_name}	= {};

				for (keys %$column_data)
				{
					next if (! defined($$column_data{$_}) );

					$$self{'_info'}{$table_name}{'columns'}{$column_name}{$_} = $$column_data{$_};
				}
			}
		}

	}	# End of _info.

	sub _standard_keys
	{
		keys %_attr_data;
	}

}	# End of encapsulated class data.

# -----------------------------------------------

sub columns
{
	my($self, $table, $by_position) = @_;

	if ($by_position)
	{
		[sort{$$self{'_info'}{$table}{'columns'}{$a}{'ORDINAL_POSITION'} <=> $$self{'_info'}{$table}{'columns'}{$b}{'ORDINAL_POSITION'} } keys %{$$self{'_info'}{$table}{'columns'} }];
	}
	else
	{
		[sort{$a cmp $b} keys %{$$self{'_info'}{$table}{'columns'} }];
	}

}	# End of columns.

# -----------------------------------------------

sub info
{
	my($self) = @_;

	$$self{'_info'};

}	# End of info.

# -----------------------------------------------

sub new
{
	my($class, %arg)	= @_;
	my($self)			= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	croak(__PACKAGE__ . ". You must supply a value for the 'dbh' parameter") if (! $$self{'_dbh'});

	$self -> _info();

	return $self;

}	# End of new.

# -----------------------------------------------

sub refresh
{
	my($self) = @_;

	$self -> _info();

}	# End of refresh.

# -----------------------------------------------

sub tables
{
	my($self) = @_;

	[sort keys %{$$self{'_info'} }];

}	# End of tables.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<DBIx::Admin::TableInfo> - A wrapper around DBI's table_info() and column_info()

=head1 Synopsis

	use DBIx::Admin::TableInfo;

	my($dbh) = DBI -> connect
	(
	    'DBI:mysql:mids:127.0.0.1', 'root', 'pass',
	    {
	        AutoCommit         => 1,
	        PrintError         => 0,
	        RaiseError         => 1,
	        ShowErrorStatement => 1,
	    }
	);
	my($admin) = DBIx::Admin::TableInfo -> new(dbh => $dbh);
	my($info)  = $admin -> info();

	for my $table_name (@{$admin -> tables()})
	{
	    print "Table: $table_name\n";
	    print "Table attributes\n";

	    for (sort keys %{$$info{$table_name}{'attributes'} })
	    {
	        print "$_: $$info{$table_name}{'attributes'}{$_}\n";
	    }

	    print "\n";

	    for my $column_name (@{$admin -> columns($table_name)})
	    {
	        print "Column: $column_name\n";
	        print "Column attributes\n";

	        for (sort keys %{$$info{$table_name}{'columns'}{$column_name} })
	        {
	            print "$_: $$info{$table_name}{'columns'}{$column_name}{$_}\n";
	        }

	        print "\n";
	    }

	    print "\n";
	}

=head1 Description

C<DBIx::Admin::TableInfo> is a pure Perl module.

It is a wrapper around the DBI methods table_info() and column_info().

=head1 Distributions

This module is available both as a Unix-style distro (*.tgz) and an
ActiveState-style distro (*.ppd). The latter is shipped in a *.zip file.

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing each type of distro.

=head1 Constructor and initialization

new(...) returns a C<DBIx::Admin::TableInfo> object.

This is the class's contructor.

Usage: DBIx::Admin::TableInfo -> new().

This method takes a set of parameters. Only the dbh parameter is mandatory.

For each parameter you wish to use, call new as new(param_1 => value_1, ...).

=over 4

=item column_catalog

This is the value passed in as the catalog parameter to column_info(catalog, schema...).

The default value is undef.

undef was chosen because it given the best results with MySQL. The MySQL driver DBD::mysql V 2.9002 has a bug in it,
in that it aborts if an empty string is used here, even though an empty string is used for the catalog parameter to
table_info().

This parameter is optional.

=item column_schema

This is the value passed in as the schema parameter to column_info(catalog, schema...).

The default value is undef.

See above for comments about undef.

This parameter is optional.

=item dbh

This is a database handle.

This parameter is mandatory.

=item table_catalog

This is the value passed in as the catalog parameter to table_info(catalog, schema...).

The default value is '' (the empty string).

See above for comments about empty strings.

This parameter is optional.

=item table_schema

This is the value passed in as the schema parameter to table_info(catalog, schema...).

The default value is '' (the empty string).

See above for comments about empty strings.

This parameter is optional.

=back

=head1 Method: columns($table_name, $by_position)

Returns an array ref of column names.

By default they are sorted by name.

However, if you pass in a true value for $by_position, they are sorted by the column attribute ORDINAL_POSITION.

=head1 Method: info()

Returns a hash ref of all available data.

The structure of this hash is described next:

=over 4

=item First level: The keys are the names of the tables

	my($info)       = $obj -> info();
	my(@table_name) = sort keys %$info;

I use singular names for my arrays, hence @table_name rather than @table_names.

=item Second level: The keys are 'attributes' and 'columns'

	my($table_attributes) = $$info{$table_name}{'attributes'};

This is a hash ref of the table's attributes.

	my($columns) = $$info{$table_name}{'columns'};

This is a hash ref of the table's columns.

=item Third level: Table attributes

	while ( ($name, $value) = each(%$table_attributes) )
	{
		Use...
	}

For the attributes of the tables, there are no more levels in the hash ref.

=item Third level: The keys are the names of the columns.

	my(@column_name) = sort keys %$columns;

=item Fourth level: Column attributes

	for $column_name (@column_name)
	{
	    while ( ($name, $value) = each(%{$columns{$column_name} }) )
	    {
		    Use...
	    }
	}

=back

=head1 Method: tables()

Returns an array ref of table names.

They are sorted by name.

=head1 Example code

See the examples/ directory in the distro.

There are 2 demo programs:

=over 4

=item test-admin-info.cgi

It outputs all possible info in HTML.

=item test-admin-info.pl

It outputs all possible info in text.

=back

=head1 Tested Database Formats

I have used the program in the synopsis to read databases in these formats:

=over 4

=item MySQL V 4.0

=item MS Access V 2

Yes, some businesses are still running V 2 as of July, 2004.

=item MS Access V 2002

=back

It's important to note that in each case the only parameter that needed to be passed to C<new()> was dbh.

=head1 Related Modules

I have written a set of modules - which are still being tested - under the DBIx::Admin::* namespace.

They will form the core of myadmin.cgi V 2. See http://savage.net.au/Perl-tutorials.html#tut_41

=head1 Required Modules

Carp.

=head1 Changes

See Changes.txt.

=head1 Author

C<DBIx::Admin::TableInfo> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2004.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2004, Ron Savage. All rights reserved.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
