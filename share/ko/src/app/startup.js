import 'jquery';
import 'bootstrap';
import ko from 'knockout';
import 'knockout-projections'
import * as router from './router';

ko.bindingHandlers.clickToggler = {
    init: function (el, valueAcc) {
        var value = valueAcc();

        ko.utils.registerEventHandler(el, 'click', function() {
            value(!value());
            $(el).blur();
        });
    }
};
ko.bindingHandlers.clickBlur = {
    init: function (el, valueAcc, allBindingsAcc, data, context) {
        var value = valueAcc();

        ko.utils.registerEventHandler(el, 'click', () => {
            $(el).blur();
        });
        ko.bindingHandlers.click.init(el, valueAcc, allBindingsAcc, data, context);
    }
}

// Components can be packaged as AMD modules, such as the following:
ko.components.register('navbar', { require: 'components/navbar/navbar' });
ko.components.register('home-page', { require: 'components/home-page/home' });

// ... or for template-only components, you can just point to a .html file directly:
ko.components.register('about-page', {
    template: { require: 'text!components/about-page/about.html' }
});

ko.components.register('redis-key-row', { require: 'components/redis/key-row' });

ko.components.register('redis-table', { require: 'components/redis/table' });

// [Scaffolded component registrations will be inserted here. To retain this feature, don't remove this comment.]

// Start the application
ko.applyBindings({ route: router.currentRoute });
