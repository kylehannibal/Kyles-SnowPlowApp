let stripe_key = "sk_test_kmalEu8eu83t1jTSrVkdTA2K";
let Stripe = require("stripe")(stripe_key);

Parse.Cloud.define("purchaseItem", function(request, response) {
  let item, order;

  Parse.Promise.as().then(function() {

    let itemQuery = new Parse.Query('Item');
    itemQuery.equalTo('ItemName', request.params.ItemName);
        return itemQuery.first(null,{useMasterKey: true}).then(null, function(error) {
            return Parse.Promise.error('Sorry, this item is no longer available.');
        });
    },{useMasterKey: true}).then(function(result) {
        if (!result) {
            return Parse.Promise.error('Sorry, this item is no longer available.');
        } else if (result.get('quantityAvailable') <= 0) {
            return Parse.Promise.error('Sorry, this item is out of stock.');
        }
        item = result;
        item.increment('quantityAvailable', -1);
        return item.save(null,{useMasterKey: true}).then(null, function(error) {
            console.log('Decrementing quantity failed. Error: ' + error);
            return Parse.Promise.error('An error has occurred. Your credit card was not charged. 1');
        });
    },{useMasterKey: true}).then(function(result) {
        if (item.get('quantityAvailable') < 0) { // can be 0 if we took the last
            return Parse.Promise.error('Sorry, this item is out of stock.');
        }
        //Setting the columns to Order class
        order = new Parse.Object("Order");
        order.set('name', request.params.name);
        order.set('email', request.params.email);
        order.set('address', request.params.address);
        order.set('zip', request.params.zip);
        order.set('city_state', request.params.city_state);
        order.set('item', item.get('ItemName'));
        order.set('fulfilled', true);
        order.set('charged', false);

        return order.save(null,{useMasterKey:true}).then(null, function(error) {
            item.increment('quantityAvailable', 1);
            return Parse.Promise.error('An error has occurred. Your credit card was not charged.');
        });
    },{useMasterKey:true}).then(function(order) {
        return Stripe.charges.create({
        amount: item.get('Price')*100, // It needs to convert to cents
        currency: "usd",
        source: request.params.cardToken,
        description: "Charge for " + request.params.email
    }, function(err, charge) {
        if (!err){
            order.set('stripePaymentId', charge.id);            
            order.set('charged', true);
            order.save(null,{useMasterKey:true});
        }
    });
    },{useMasterKey:true}).then(function() {
        response.success('Success');
    }, function(error) {
        response.error(error);
    });
});