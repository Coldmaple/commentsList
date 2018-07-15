pragma solidity ^0.4.18;

contract ChainList {
    // state variables
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;

    // events
    event LogSellArticle(
        address indexed _seller,
        string _name,
        uint256 _price
    );
    event LogBuyArticle(
        address indexed _seller,
        address indexed _buyer,
        string _name,
        uint256 _price
    );

    // sell article
    function sellArticle(string _name, string _description, uint256 _price) public {
        seller = msg.sender;
        name = _name;
        description = _description;
        price = _price;

        LogSellArticle(seller, name, price);
    }

    // get article
    function getArticle() public view returns (
        address _seller,
        string _name,
        string _description,
        uint256 _price
    ) {
        return(seller, name, description, price);
    }

    // buy article
    function buyArticle() payable public {
        // check if there is an article for sale
        require(seller != 0x0);

        // check the article has not been sold yet
        require(buyer == 0x0);

        // don't allow seller to buy its own article
        require(msg.sender != seller);

        // check the value sent corresponds to the price of the article
        require(msg.value == price);

        // keep buyer's information
        buyer = msg.sender;

        // the buyer can pay the seller
        seller.transfer(msg.value);

        // trigger the event
        LogBuyArticle(seller, buyer, name, price);
    }
}