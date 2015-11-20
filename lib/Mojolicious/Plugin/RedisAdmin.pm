use strict;
use warnings;

package Mojolicious::Plugin::RedisAdmin;

# VERSION
# ABSTRACT: Short intro

use Mojo::Base 'Mojolicious::Plugin';
use File::ShareDir::Tarball 'dist_dir';
use Path::Tiny;
use Data::Dump::Streamer;
use Safe::Isa;
use experimental qw/signatures postderef/;

has 'redis';

sub register($self, $app, $conf) {

    # $conf->{'redis'} should be a Mojolicious::Plugin::RedisHandler thingy.
    $self->redis($conf->{'redis'});

    $self->setup_directories($app);

    my $router = exists $conf->{'router'}    ?  $conf->{'router'}
               : exists $conf->{'condition'} ?  $app->routes->over($conf->{'condition'})
               :                                $app->routes
               ;

    my @ns = qw/namespace Mojolicious::Plugin::RedisAdmin::Controller::Public action/;

    my $r = $router->under($conf->{'url'} || 'redisadmin');

    $r->get('/')->to(@ns, 'home');

   # $router->get($url)->to(cb => sub ($c) {
   #     $self->render($c, 'viewer/schema', db => $self->schema_info($schema), schema_name => ref $schema);
   # });
}

sub setup_directories($self, $app) {

    # add our template directory
    my $template_dir = path(dist_dir('Mojolicious-Plugin-RedisAdmin'))->child(qw/templates/);

    warn 'pushes? ' . $template_dir->realpath;
    if($template_dir->is_dir) {
        push $app->renderer->paths->@* => $template_dir->realpath;
    }
    warn join ',' => $app->renderer->paths->@*;

    # add static directory
    my $public_dir = path(dist_dir('Mojolicious-Plugin-RedisAdmin'))->child('public');

    if($public_dir->is_dir) {
        push $app->static->paths->@* => $public_dir->realpath;
    }

}

1;

__END__

=pod

=head1 SYNOPSIS

    use Mojolicious::Plugin::RedisAdmin;

=head1 DESCRIPTION

Mojolicious::Plugin::RedisAdmin is ...

=head1 SEE ALSO

=cut
