// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.20;

contract AuctionV1 {

    address public owner;
    //Duration: 5 days => 1 minute = 60 seconds 1 hour = 60 × 60 = 3600 seconds.
    //1 day= 24 × 3600 = 86400 seconds 5 days = 5 × 86.400 = 432000 seconds.
    uint256 private finishedTime;

    uint256 private actualHiggestOffer;
    address private actualWinnerAddress;

    //Create a struct to contain each participants with all of their offers.
    struct Offer {
        address person;
        uint256 amount;
    }
    
    //I instantiate the struct Offer and call it offers.
    Offer [] offers;

    constructor(uint256 _durationInSeconds){
        owner = msg.sender;
        finishedTime = block.timestamp + _durationInSeconds; // pass 432000
    }

    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not allowed to do it");
        _;
    }

    modifier isOver() {
        require(canParticipate() == false, "Auction is over");
        _;
    }

    //Events
    event HigherBid(uint256 indexed _higgestOffer, string _message );
    event auctionEnded (uint256 indexed _higgestOffer, string _message);

    //To know if it is posible to participate yet.    
    function canParticipate() public view returns(bool){
        require(finishedTime > block.timestamp, "there is no more time to participate");
        return (block.timestamp > finishedTime) ? false : true;
    }

    // Bid function; adding the participant with their offer to the list.
    function makeAnOffer() payable public {
        require(canParticipate(), "The time of the bid has over");
        //If the offer is made 10 minutes before bid close, reset time 10 minutes more. 600 seconds = 10 minutes
        if (finishedTime - block.timestamp <= 600) {
            finishedTime += 600;
            }
        require(msg.value > (actualHiggestOffer + actualHiggestOffer * 5 / 100) 
        && msg.value > 0, "You have to make an offer, and it has to be 5% more than the actual higher offer");
        //Incorporating each address with the offer in the array
        offers.push(Offer({person:msg.sender, amount:msg.value})); 
        //checking if the new offer is higher than the actual higgest
        isHigher(msg.value) ? (actualHiggestOffer = msg.value) : actualHiggestOffer = actualHiggestOffer;
        actualWinnerAddress = msg.sender;
        // emiting the event if the new offer is higher than the actual
        if(isHigher(msg.value)){
        emit HigherBid(actualHiggestOffer, "There is a new higger offer");
        }
    }

    // Check if is the higger offer. Internal private function.
    function isHigher(uint256 _higher) internal view returns(bool){
        return (_higher > actualHiggestOffer);
    } 

    //Send winner offer to the owner
    function withdraw() external onlyOwner isOver{
        require(!canParticipate(), "Auction has not ended");
        for(uint256 i=0; i<offers.length; i++){
            if (offers[i].amount == actualHiggestOffer) {
                (bool success,) = owner.call{value: actualHiggestOffer}("");
                require(success);
            }
            offers[i].amount = 0;
        }
        emit auctionEnded(actualHiggestOffer, "The auction is over");
    }

    //Show all participants with their offers
    function listOfOffers() external view returns(Offer [] memory) {
        return offers;
    }

    //Allowing each participant to reedem itsealf during the bid.
    function redeem() public {
        require(canParticipate());
        for(uint256 i=0; i < offers.length; i++) {
            //Checking that the address that call this function has amount to redeem.
            if(offers[i].person == msg.sender) {
            //The winner should not be able to use it
            require(offers[i].amount < actualHiggestOffer, "The winner cannot redeem");
            // Checking person who wants to reedem actualy had make an offer
            require(offers[i].amount != 0, "You dont have money to redeem");
            // Redeem the amount less 2%; comition goes to owner
            (bool achieved,) = owner.call{value:offers[i].amount * 2 / 100}(""); 
            require(achieved);  
            (bool success,) = msg.sender.call{value:offers[i].amount - offers[i].amount * 2 / 100}("");
            require(success);
            // after redeem, set balance to 0 in order not to redeem more than he has
                offers[i].amount = 0;
                }  
            }
        }

    function actualWinner() public view returns(address, uint256){
        return (actualWinnerAddress, actualHiggestOffer);
    }

}
