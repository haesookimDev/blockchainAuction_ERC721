pragma solidity ^0.5.0;

import 'httpsgithub.comExchange-MNFT-ERC721blobmasterERC721.sol';

contract ERC721Impl is ERC721 {
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), ERC721 mint to the zero address);
        require(!_exists(tokenId), ERC721 token already minted);

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }토큰 소유권 설정 
}

contract ArtworkAuctionAndERC721 is ERC721Impl{
    
    mapping(address = uint) pendingReturns;
    
    uint public Art_ID;
    address public ArtworkOwner;
    
    
    address public highestBidder;
    uint public highestBid;
    
    bool ended = true;
    
    struct Charactor {
        string  hash;   캐릭터 이름
        uint256 level;  캐릭터 레벨
        address artOwner;  캐릭터 소유주 
    }

    Charactor[] public charactors;  default [] 
    address public owner;           컨트랙트 소유자

    constructor () public {
        owner = msg.sender; 
    } 
    
    modifier isOwner() {
      require(owner == msg.sender);
      _;
    }
    
    function mint(string memory hash, address account) public isOwner {
        uint256 cardId = charactors.length;  유일한 캐릭터 ID
        charactors.push(Charactor(hash, 1, account));
        _mint(account, cardId);  ERC721 소유권 등록
    } 캐릭터 생성
    
    function lookupTokenCount() public view returns(uint256 tokenCount) {
        tokenCount = charactors.length;
    }토큰 개수 탐색   
    
    function startAuction(uint ID) public {
        require(ended);
        require(_exists(ID), ERC721 approved query for nonexistent token);
        require(_isApprovedOrOwner(msg.sender, ID), ERC721 transfer caller is not owner nor approved);
        Art_ID = ID;
        ArtworkOwner=msg.sender;
        ended = false;
        highestBid = 0;
    }경매 시작
    
    function lookUpAuction() public view returns (uint tokenID, string memory hashName, address ArtOwner, address _highestBidder, uint _highestBid) {
        require(!ended);
        tokenID = Art_ID;
        hashName = charactors[Art_ID].hash;
        ArtOwner = ArtworkOwner;
        _highestBidder = highestBidder;
        _highestBid = highestBid;
    }경매 현황
    
    function bid() public payable {
        require(!ended);
        require(msg.value = highestBid);

        highestBidder.call.value(highestBid)();
        
        highestBidder = msg.sender;
        highestBid = msg.value;
    }입찰
     
    function end_Actions() public {
        require(!ended);
        require(ArtworkOwner == msg.sender);
        require(_isApprovedOrOwner(msg.sender, Art_ID), ERC721 transfer caller is not owner nor approved);
        
        ended = true;
        ArtworkOwner.call.value(highestBid)();
        _transferFrom(msg.sender, highestBidder, Art_ID);
        charactors[Art_ID].artOwner = highestBidder;
    }경매 종료   
}