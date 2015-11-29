import ko from 'knockout';
import templateMarkup from 'text!./table.html';

class RedisTableItem {
    constructor(params) {
        this.key = ko.observable(params.key);
        this.actual_key = ko.observable(params.actual_key);
        this.fetch_ttl = ko.observable(false);
        this.ttl = ko.observable();
        this.keyValue = ko.observable();
        this.open = ko.observable(false);
    }

    fetchValue() {
        var self = this;
        console.log('fetches..');
        if(this.open() && this.keyValue() === undefined) {
            console.log('..really!');
            $.get('/key/' + this.actual_key() + '/value', (data) => {
                try {
                    self.keyValue(JSON.stringify(JSON.parse(data.value), null, 2));
                }
                catch(e) {
                    self.keyValue(data.value);
                }
            });
        }
    }

}

class RedisTable {
    constructor(params) {
        this._ttl_timer_seconds = 2;
        this.message = ko.observable('Hello from the redis/table component!');
        this.items = ko.observableArray([]);
        this.ttl_timer_interval = ko.observable(this._ttl_timer_seconds);
        this.ttl_timer = this.start_ttl();

        this.scanDatabases();
    }
    
    scanDatabases() {
        var self = this;
        $.getJSON('/scan', function(data) {
            self.items($.map(data, function(item) {
                return new RedisTableItem(item)
            }));
        });
        
    }
    removeKey (item) {
        var self = this;
        $.post('/delete/key/' + item.actual_key(),
            function(data) {
                if(data.result === 1) {
                    self.items.remove(item);
                }
            },
            'json'
        );
    }
    fetchTTL (item) {
        item.fetch_ttl(true);
        console.log(item.fetch_ttl());
    }

    start_ttl() {
        var self = this;
        return setInterval(function() {
            var newTimer = self.ttl_timer_interval() - 1;

            if(newTimer <= 0) {
                var want_ttl_keys = $.map($.grep(self.items(), (item, i) => { return item.fetch_ttl() }), (item) => { return item.actual_key() });

                if(want_ttl_keys.length > 0) {
                    $.getJSON('/command/TTL', { keys : want_ttl_keys }, function(data) {
                        var keydata = data.keys;
                        for (var i = 0; i < keydata.length; i++) {
                            var items = $.grep(self.items(), function(item) { return item.actual_key() === keydata[i]['key'] });
                            if(items.length == 1) {
                                var ttl = keydata[i]['ttl'];

                                if(ttl === -2) {
                                    self.items.remove(items[0]);
                                }
                                else if(ttl === -1) {
                                    items[0].ttl('∞');
                                }
                                else {
                                    items[0].ttl(ttl);
                                }
                            }
                        }
                    });
                }
                self.ttl_timer_interval(self._ttl_timer_seconds);
            }
            else {
                self.ttl_timer_interval(newTimer);
            }
        }, 1000);

    }



    dispose() {
        console.log(clearTimeout(this.ttl_timer));
    }
}

export default { viewModel: RedisTable, template: templateMarkup };
