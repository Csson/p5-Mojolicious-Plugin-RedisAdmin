use 5.20.0;
use strict;
use warnings;

package RedisAdminApp {
    
    use Mojo::Base 'Mojolicious';
    use Mojo::Util 'steady_time';
    use experimental qw/postderef signatures/;

    # VERSION
    # ABSTRACT: ..

    sub startup($self) {
        $self->setup_helpers;
        $self->setup_hooks;
        $self->setup_routes;
    }

    sub setup_routes($self) {

  #      my $r = $self->routes;

  #      $r->get('/')->to('public#round')->name('home');

    #    my $api = $r->under('/api');
    #    $api->get('points-per-hour/:round_id', [format => ['json']])->name('api_points_per_hour')->to('public#api_points_per_hour');
    #    $api->get('round-points/:round_id', [format => ['json']])->name('api_round_points')->to('public#api_round_points');
    #    $api->get('owned-zones/:round_id', [format => ['json']])->name('api_owned_zones')->to('public#api_owned_zones');
    #    $api->get('points-per-day/:round_id', [format => ['json']])->name('api_points_per_day')->to('public#api_points_per_day');


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
        $self->plugin(RedisAdmin => { redis => $self->redis });

    }

    sub setup_hooks($self) {
        $self->hook(around_action => sub {
            my($next, $c, $action, $last) = @_;

            my $starttime = steady_time;
            $next->();
            $self->log->debug(sprintf 'Time to render <%s>: %f for %s using %s', $c->req->url, steady_time - $starttime, $c->tx->remote_address, $c->req->headers->user_agent);
        });
    }

}

1;
