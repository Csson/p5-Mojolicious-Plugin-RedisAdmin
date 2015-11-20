use 5.20.0;
use strict;
use warnings;

package App::RedisMin {
    
    use Mojo::Base 'Mojolicious';
    use Mojo::Util 'steady_time';
    use Mojo::Base 'Mojolicious::Plugin';
    use File::ShareDir::Tarball 'dist_dir';
    use Path::Tiny;
    use Data::Dump::Streamer;
    use Safe::Isa;
    use experimental qw/signatures postderef/;

    # VERSION
    # ABSTRACT: ..

    sub startup($self) {
        $self->setup_directories;
        $self->setup_helpers;
        $self->setup_hooks;
        $self->setup_routes;
    }

    sub setup_routes($self) {
        my $r = $self->routes;

        $r->get('/')->to('public#home');

    }

    sub setup_helpers($self) {
        $self->secrets(['asdfasdfasf']);
        $self->defaults(layout => 'default');
        $self->plugin('UnicodeNormalize');
        $self->plugin('BootstrapHelpers');

        $self->plugin(RedisHandler => {
            helper => 'redis',
            server => 'localhost:6379',
            database => 0,
        });
    }

    sub setup_hooks($self) {
        $self->hook(around_action => sub {
            my($next, $c, $action, $last) = @_;

            my $starttime = steady_time;
            $next->();
            $self->log->debug(sprintf 'Time to render <%s>: %f for %s using %s', $c->req->url, steady_time - $starttime, $c->tx->remote_address, $c->req->headers->user_agent);
        });
    }

    sub setup_directories($self) {

        # add our template directory
        if(path(qw/share templates/)->exists) {
            push $self->renderer->paths->@* => path(qw/share templates/)->realpath;
        }
        my $template_dir = path(dist_dir('App-RedisMin'))->child(qw/templates/);

        if($template_dir->is_dir) {
            push $self->renderer->paths->@* => $template_dir->realpath;
        }

        # add static directory
        if(path(qw/share public/)->exists) {
            push $self->static->paths->@* => path(qw/share public/)->realpath;
        }
        my $public_dir = path(dist_dir('App-RedisMin'))->child('public');

        if($public_dir->is_dir) {
            push $self->static->paths->@* => $public_dir->realpath;
        }

    }
}

1;
