// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}

contract SocialTipping is ReentrancyGuard {
    struct Creator {
        address owner;
        string handle;
        uint256 totalReceived;
        uint256 tipCount;
        uint256 balance;
        bool active;
    }

    struct Tip {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        string message;
    }

    Creator[] public creators;
    mapping(address => uint256) public creatorIndex;
    mapping(address => bool) public isCreator;

    Tip[] public tips;
    mapping(address => uint256[]) public creatorTips;
    mapping(address => uint256[]) public senderTips;

    uint256 public totalTipsVolume;

    event CreatorRegistered(address indexed creator, string handle);
    event Tipped(address indexed from, address indexed to, uint256 amount, string message);
    event TipsWithdrawn(address indexed creator, uint256 amount);

    function registerCreator(string calldata handle) external {
        require(!isCreator[msg.sender], "Already registered");
        creators.push(Creator(msg.sender, handle, 0, 0, 0, true));
        creatorIndex[msg.sender] = creators.length - 1;
        isCreator[msg.sender] = true;
        emit CreatorRegistered(msg.sender, handle);
    }

    function tip(address creator, string calldata message) external payable nonReentrant {
        require(isCreator[creator], "Not a creator");
        require(msg.value > 0, "Zero tip");
        require(creator != msg.sender, "Cannot self tip");

        Creator storage c = creators[creatorIndex[creator]];
        c.totalReceived += msg.value;
        c.tipCount += 1;
        c.balance += msg.value;

        tips.push(Tip(msg.sender, creator, msg.value, block.timestamp, message));
        uint256 tid = tips.length - 1;
        creatorTips[creator].push(tid);
        senderTips[msg.sender].push(tid);
        totalTipsVolume += msg.value;

        emit Tipped(msg.sender, creator, msg.value, message);
    }

    function withdrawTips() external nonReentrant {
        require(isCreator[msg.sender], "Not a creator");
        Creator storage c = creators[creatorIndex[msg.sender]];
        uint256 amount = c.balance;
        require(amount > 0, "Nothing to withdraw");
        c.balance = 0;
        payable(msg.sender).transfer(amount);
        emit TipsWithdrawn(msg.sender, amount);
    }

    function creatorStats(address who) external view returns (uint256 received, uint256 count, uint256 balance, bool active) {
        if (!isCreator[who]) return (0, 0, 0, false);
        Creator storage c = creators[creatorIndex[who]];
        return (c.totalReceived, c.tipCount, c.balance, c.active);
    }

    function tipCount() external view returns (uint256) {
        return tips.length;
    }
}
