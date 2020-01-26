pragma solidity ^0.5.0;

/*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {
    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address public owner;
    uint256 TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    struct Event {
        string description;
        string website;
        uint256 totalTickets;
        uint256 sales;
        mapping(address => uint256) buyers;
        bool isOpen;
    }

    Event myEvent;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address purchaser, uint256 number);
    event LogGetRefund(address purchaser, uint256 number);
    event LogEndSale(address owner, uint256 balance);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized!");
        _;
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor(
        string memory description,
        string memory website,
        uint256 tickets
    ) public {
        owner = msg.sender;
        myEvent.description = description;
        myEvent.website = website;
        myEvent.totalTickets = tickets;
        myEvent.isOpen = true;
    }

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public
        view
        returns (
            string memory description,
            string memory website,
            uint256 totalTickets,
            uint256 sales,
            bool isOpen
        )
    {
        return (
            myEvent.description,
            myEvent.website,
            myEvent.totalTickets,
            myEvent.sales,
            myEvent.isOpen
        );
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address buyer) public view returns (uint256) {
        return myEvent.buyers[buyer];
    }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    function buyTickets(uint256 numberOfTickets) public payable {
        require(myEvent.isOpen, "Event is not open!");
        require(
            msg.value >= TICKET_PRICE * numberOfTickets,
            "Transaction value is NOT sufficient for the number of tickets requested!"
        );
        require(
            numberOfTickets <= myEvent.totalTickets - myEvent.sales,
            "You have requested more tickets than available!"
        );

        myEvent.sales = myEvent.sales + numberOfTickets;
        myEvent.buyers[msg.sender] = numberOfTickets;

        uint256 refundValue = msg.value - numberOfTickets * TICKET_PRICE;
        msg.sender.transfer(refundValue);

        emit LogBuyTickets(msg.sender, numberOfTickets);
    }

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
    function getRefund() public {
        require(
            myEvent.buyers[msg.sender] > 0,
            "You haven't purchased any tickets!"
        );

        myEvent.sales = myEvent.sales - myEvent.buyers[msg.sender];

        uint256 refundValue = myEvent.buyers[msg.sender] * TICKET_PRICE;
        msg.sender.transfer(refundValue);

        emit LogGetRefund(msg.sender, myEvent.buyers[msg.sender]);
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    function endSale() public onlyOwner {
        myEvent.isOpen = false;

        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);

        emit LogEndSale(msg.sender, balance);
    }

}
