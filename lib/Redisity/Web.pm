use 5.20.0;
use strict;
use warnings;

package Redisity::Web {
    
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

        $r->get('/')->to(cb => sub ($c) { $c->reply->static('index.html'); });
        $r->get('/scan')->to('public#scan')->name('scan');
        $r->get('/command/:command/*key')->to('public#command')->name('run_command');
        $r->get('/command/:command')->to('public#command')->name('run_command');
        $r->post('/delete/key/*key')->to('public#delete_key')->name('delete_key');
        $r->get('/key/:key/value')->to('public#get_key_value')->name('get_key_value');

    }

    sub setup_helpers($self) {
        $self->secrets(['asdfasdfasf']);
        $self->defaults(layout => 'default');
        $self->plugin('UnicodeNormalize');
        $self->plugin(BootstrapHelpers => {
            icons => {
                class => 'glyphicon',
                formatter => 'glyphicon-%s',
            },
        });

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
            $self->renderer->paths([path(qw/share templates/)->realpath]);
        }
        else {
            my $template_dir = path(dist_dir('App-RedisMin'))->child(qw/templates/);

            if($template_dir->is_dir) {
                $self->renderer->paths([$template_dir->realpath]);
            }
        }

        # add static directory
        if(path(qw/share public/)->exists) {
            $self->static->paths([path(qw/share public/)->realpath]);
        }
        else {
            my $public_dir = path(dist_dir('App-RedisMin'))->child('public');

            if($public_dir->is_dir) {
                $self->static->paths([$public_dir->realpath]);
            }
        }

    }
}

1;
