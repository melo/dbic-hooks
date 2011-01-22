package DBICx::Hooks::Registry;

# ABSTRACT: Provide hooks into DBIx::Class create()/update()

use strict;
use warnings;
use Carp 'confess';
use parent 'Exporter';

@DBICx::Hooks::Registry::EXPORT = qw( dbic_hooks_register dbic_hooks_for );


=function dbic_hooks_register

    dbic_hooks_register('Source', 'Action', sub { my $row = shift; ... });
    dbic_hooks_register($row_obj, 'Action', sub { my $row = shift; ... });
    dbic_hooks_register($rs_obj,  'Action', sub { my $row = shift; ... });

The C<dbic_hooks_register> function takes a pair C<Source>/C<Action> and
a callback. The callback will be called after the specified C<Action> is
performed on C<Source>.

The following C<Action>'s are supported: C<create> and C<update>.

The C<create> action will be called after a new row is created on C<Source>.

The C<update> action is called when the update() method is called on a
L<DBIx::Class::Row|DBIx::Class::Row> object. Note that if all the fields
are updated to the same values as the current ones, no C<UPDATE> SQL
command is actually sent to the database server, but the callback will
be called anyway.

All the callbacks receive a single parameter, the
L<DBIx::Class::Row|DBIx::Class::Row> object that was created or
modified.


=function dbic_hooks_for

    @list_of_cbs = dbic_hooks_for('Source', 'Action');
    @list_of_cbs = dbic_hooks_for($row_obj, 'Action');
    @list_of_cbs = dbic_hooks_for($rs_obj,  'Action');

Returns in list context a possibly empty list of callbacks for a pair
C<Source>/C<Action>. In scalar context returns the number of elements
in the list.

=cut

{
  my %registry;

  sub dbic_hooks_register {
    my ($source, $action, $cb) = @_;
    confess("Missing required first parameter 'source', ")
      unless $source;

    confess("Missing required second parameter 'action', ")
      unless $action;
    confess(
      "Action '$action' not supported, only 'create', 'update' or 'delete', ")
      unless $action eq 'create'
        or $action eq 'update'
        or $action eq 'delete';

    confess("Missing required third parameter 'callback', ")
      unless $cb;
    confess("Parameter 'callback' must be a coderef, ")
      unless ref($cb) eq 'CODE';

    my $list = $registry{$source}{$action} ||= [];
    push @$list, $cb;

    return;
  }

  sub dbic_hooks_for {
    my ($source, $action) = @_;

    my $list = [];
    $list = $registry{$source}{$action}
      if exists $registry{$source} and exists $registry{$source}{$action};

    return @$list if wantarray;
    return scalar(@$list);
  }
}

1;

__END__

=head1 SYNOPSIS

    package SomeClass;
    
    use DBICx::Hooks::Registry;
    
    dbic_hooks_register('My::Schema::Result::MySource', 'create', sub {
      my ($row) = @_;
      
      print "A new row was created, id is ", $row->id, "\n";
    });
    
    dbic_hooks_register('My::Schema::Result::MySource', 'update', sub {
      my ($row) = @_;
      
      print "The row with id is ", $row->id, " was updated\n";
    });

=head1 DESCRIPTION

To register a callback with a specific Source/Action pair, you use this
registry functions.

=cut
