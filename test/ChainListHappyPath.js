// Contract to be tested
var ChainList = artifacts.require('./ChainList.sol');

contract('ChainList', function(accounts) {
    var chainListInstance;
    var seller = accounts[1];
    var articleName = 'A good book';
    var articleDescription = 'This is a good book';
    var articlePrice = 100;

    it('should be initialized with empty values', function() {
        return ChainList.deployed()
            .then(function(instance) {
                chainListInstance = instance;
                return chainListInstance.getArticle();
            })
            .then(function(data) {
                assert.equal(data[0], 0x0, 'seller must be empty');
                assert.equal(data[1], '', 'article must be empty');
                assert.equal(data[2], '', 'description must be empty');
                assert.equal(data[3].toNumber(), 0, 'price must be empty');
            });
    });

    // Test case: sell an article
    it('should sell an article', function() {
        return ChainList.deployed()
            .then(function(instance) {
                chainListInstance = instance;
                return chainListInstance.sellArticle(
                    articleName,
                    articleDescription,
                    web3.toWei(articlePrice, 'ether'),
                    { from: seller }
                );
            })
            .then(function() {
                return chainListInstance.getArticle();
            })
            .then(function(data) {
                assert.equal(data[0], seller, 'seller must be ' + seller);
                assert.equal(
                    data[1],
                    articleName,
                    'article must be ' + articleName
                );
                assert.equal(
                    data[2],
                    articleDescription,
                    'description must be ' + articleDescription
                );
                assert.equal(
                    data[3].toNumber(),
                    web3.toWei(articlePrice, 'ether'),
                    'price must be ' + web3.toWei(articlePrice, 'ether')
                );
            });
    });

    // Test case: log sell article event
    it('should trigger an event when a new article is sold', function() {
        return ChainList.deployed()
            .then(function(instance) {
                chainListInstance = instance;
                return chainListInstance.sellArticle(
                    articleName,
                    articleDescription,
                    web3.toWei(articlePrice, 'ether'),
                    { from: seller }
                );
            })
            .then(function(receipt) {
                assert.equal(
                    receipt.logs.length,
                    1,
                    'one event should have been triggered'
                );
                assert.equal(
                    receipt.logs[0].event,
                    'LogSellArticle',
                    'event should be LogSellArticle'
                );
                assert.equal(
                    receipt.logs[0].args._seller,
                    seller,
                    'event seller must be ' + seller
                );
                assert.equal(
                    receipt.logs[0].args._name,
                    articleName,
                    'event article name must be ' + articleName
                );
                assert.equal(
                    receipt.logs[0].args._price.toNumber(),
                    web3.toWei(articlePrice, 'ether'),
                    'event article price must be ' +
                        web3.toWei(articlePrice, 'ether')
                );
            });
    });
});
