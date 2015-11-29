ko.bindingHandlers.clickToggler = {
    init: function (el, valueAcc) {
        var value = valueAcc();

        ko.utils.registerEventHandler(el, 'click', function() {
            value(!value());
        });
    }
};

function Item(data) {
    self = this;
    self.key = ko.observable(data.key);
    self.actual_key = ko.observable(data.actual_key);
    self.fetch_ttl = ko.observable(false);
    self.ttl = ko.observable();

}

function ItemListViewModel() {
    var ttl_timer_seconds = 2;

    var self = this;
    self.items = ko.observableArray();
    self.ttl_timer = ko.observable(ttl_timer_seconds);

    self.scanDatabases = function() {
        $.getJSON('/scan', function(data) {
            self.items($.map(data, function(item) { return new Item(item) }));
        });
    };
    self.removeKey = function(item) {
        $.post('/delete/key/' + item.actual_key(),
            function(data) {
                if(data.result === 1) {
                    self.items.remove(item);
                }
            },
            'json'
        );
    };

    setInterval(function() {
        var newTimer = self.ttl_timer() - 1;
        if(newTimer <= 0) {
            var want_ttl_keys = $.map($.grep(self.items(), function(item, i) { return item.fetch_ttl() }), function(item) { return item.actual_key() });

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
            self.ttl_timer(ttl_timer_seconds);
        }
        else {
            self.ttl_timer(newTimer);
        }
    }, 1000);

    self.scanDatabases();
}


$(document).ready(function() {
    ko.applyBindings(new ItemListViewModel());
});