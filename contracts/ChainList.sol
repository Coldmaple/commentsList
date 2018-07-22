pragma solidity ^0.4.18;

import './Ownable.sol';

contract ChainList is Ownable {

    // custom types
    struct Article {
        uint id;
        address seller;
        address buyer;
        string name;
        string description;
        uint256 price;
    }

    // state variables
    mapping (uint => Article) public articles;
    uint articleCounter;

    // events
    event LogSellArticle(
        uint indexed _id,
        address indexed _seller,
        string _name,
        uint256 _price
    );
    event LogBuyArticle(
        uint indexed _id,
        address indexed _seller,
        address indexed _buyer,
        string _name,
        uint256 _price
    );

    // deactivate the contract
    function kill() public onlyOwner {
        selfdestruct(owner);
    }

    // sell article
    function sellArticle(string _name, string _description, uint256 _price) public {
        // increment article counter
        articleCounter++;

        // store this article
        articles[articleCounter] = Article(
            articleCounter,
            msg.sender,
            0x0, 
            _name,
            _description,
            _price
        );

        LogSellArticle(articleCounter, msg.sender, _name, _price);
    }

    // fetch number of article
    function getNumberOfArticles() public view returns (uint) {
        return articleCounter;
    }

    // fetch and return all article ids for articles on sale
    function getArticlesForSale() public view returns (uint[]) {
        // prepare output array
        uint[] memory articleIds = new uint[](articleCounter);
        uint numberOfArticlesForSale = 0;

        for (uint i = 1; i <= articleCounter; i++) {
            // keep the id if the article is still for sale
            if (articles[i].buyer == 0x0) {
                articleIds[numberOfArticlesForSale] = articles[i].id;
                numberOfArticlesForSale++;
            }
        }

        // copy the articleIds array into a smaller forSale array
        uint[] memory forSale = new uint[](numberOfArticlesForSale);

        for (uint j = 0; j < numberOfArticlesForSale; j++) {
            forSale[j] = articleIds[j];
        }

        return forSale;
    }

    // buy article
    function buyArticle(uint _id) payable public {
        // check if there is at least an article for sale
        require(articleCounter > 0);

        // check that the article exist
        require(_id > 0 && _id <= articleCounter);

        // retrieve the article from the mapping
        Article storage article = articles[_id];

        // check the article has not been sold yet
        require(article.buyer == 0x0);

        // don't allow seller to buy its own article
        require(msg.sender != article.seller);

        // check the value sent corresponds to the price of the article
        require(msg.value == article.price);

        // keep buyer's information
        article.buyer = msg.sender;

        // the buyer can pay the seller
        article.seller.transfer(msg.value);

        // trigger the event
        LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
    }
}