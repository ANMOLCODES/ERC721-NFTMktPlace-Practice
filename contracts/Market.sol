// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721.sol";

contract Market {

    //public - anyone can call
    //private - only function within this contract can call
    //internal - only this contract and inheriting contracts
    //external - only external calls, functions within this contracts cant
    
    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    struct Listing {
        ListingStatus status;
        address seller;
        address token;
        uint tokenId;
        uint price;
    }

    event Listed(
        address seller,
        address token,
        uint tokenId,
        uint price,
        uint listingId
    ); //event goes off when someone lists an item

    event Sale(
        address buyer,
        address token,
        uint tokenId,
        uint price,
        uint listingId
    ); //event for when someone buys an item

    event Cancel(
        address seller,
        uint listingId    
    );

    uint private _listingId = 0;
    mapping(uint => Listing) private _listings;

    function listToken(address token, uint tokenId, uint price) public {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        Listing memory listing = Listing(
            ListingStatus.Active,
            msg.sender,
            token,
            tokenId,
            price
        );

        _listingId++;

        _listings[_listingId] = listing;

        emit Listed(
            msg.sender, 
            token,
            tokenId,
            price,
            _listingId
        ); //event emitted when someone lists an item
    }

    function getListing(uint listingId) public view returns (Listing memory){
        return _listings[listingId];
    }

    //external because all the calls will come from users i.e. outside the contract
    function buyToken(uint listingId) external payable {
        Listing storage listing = _listings[listingId]; //creates direct pointer to _listings mapping
    
        require(listing.status == ListingStatus.Active, "Listing is not active");
        // if (listing.status != ListingStatus.Active) {
        //     revert("Listing is not active");
        // }
        require(msg.sender != listing.seller, "Seller cannot be buyer");
        
        require(msg.value>=listing.price, "Insufficient payment");
        
        listing.status = ListingStatus.Sold;
        
        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenId);
        payable(listing.seller).transfer(listing.price);

        emit Sale(
            msg.sender,
            listing.token,
            listing.tokenId,
            listing.price,
            listingId
        ); //event emitted when someone buys an item
    }

    function cancel(uint listingId) public {
        Listing storage listing = _listings[listingId]; //creates direct pointer to _listings mapping
    
        require(listing.status == ListingStatus.Active, "Listing is not active");
        require(msg.sender == listing.seller, "Only seller can cancel a listing"); //making sure that canceller is the seller only

        listing.status = ListingStatus.Cancelled; //marking the listing as cancelled

        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenId); //sending back token from the contract address to the orignal seller's address (msg.sender) because they cancelled the listing
    
        emit Cancel(
            listing.seller,
            listingId
        );
    }
}