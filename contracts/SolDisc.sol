//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract SolDisc {
    struct Account {
        string name;
        string bio;
        uint256 creationDate;
        bytes32[] commentHashes;
        mapping(bytes32 => bool) likedComments;
    }

    struct Comment {
        address user;
        uint256 creationDate;
        uint256 editDate;
        uint256 numLikes;
        string text;
        // helper variables, populated for user specific `get` calls
        bool liked;
        string userName;
    }

    address[] public addressRegistry;
    mapping(bytes32 => address) public userNameRegistry;
    mapping(bytes32 => Comment) public commentRegistry;
    mapping(address => Account) public accounts;
    mapping(bytes32 => bytes32[]) commentHashesByPostHash;

    /* ----------------- External ----------------- */

    function createAccountAndComment(
        string calldata name,
        string calldata bio,
        bytes32 postHash,
        string calldata text
    ) external {
        createOrEditAccount(name, bio);
        commentOnPost(postHash, text);
    }

    function createOrEditAccount(string calldata name, string calldata bio) public {
        require(isValidUserName(name, 4, 20), 'INVALID_NAME');
        if (bytes(bio).length > 0) require(bytes(bio).length < 150, 'INVALID_BIO');

        bytes32 userNameHash = keccak256(abi.encodePacked(name));
        address userNameOwner = userNameRegistry[userNameHash];

        require(userNameOwner == address(0) || userNameOwner == msg.sender, 'USER_NAME_ALREADY_TAKEN');
        userNameRegistry[userNameHash] = msg.sender;

        Account storage account = accounts[msg.sender];

        if (account.creationDate == 0) {
            account.creationDate = block.timestamp;
            addressRegistry.push(msg.sender);
        } else {
            bytes32 oldUserNameHash = keccak256(abi.encodePacked(account.name));
            userNameRegistry[oldUserNameHash] = address(0);
        }

        account.name = name;
        account.bio = bio;
    }

    function commentOnPost(bytes32 postHash, string calldata text) public requiresAccount {
        require(isValidComment(text), 'INVALID_COMMENT');

        uint256 commentId = commentHashesByPostHash[postHash].length;
        bytes32 commentHash = _getCommentHash(postHash, commentId);

        // add comment to registry
        Comment storage comment = commentRegistry[commentHash];
        comment.user = msg.sender;
        comment.creationDate = block.timestamp;
        comment.text = text;

        // register comment to post
        commentHashesByPostHash[postHash].push(commentHash);

        // link comment to user account
        accounts[msg.sender].commentHashes.push(commentHash);
    }

    function editComment(
        bytes32 postHash,
        uint256 commentId,
        string calldata text
    ) external {
        require(isValidComment(text), 'INVALID_COMMENT');
        Comment storage comment = _getComment(postHash, commentId);

        require(comment.user == msg.sender, 'NOT_COMMENT_CREATOR');

        comment.editDate = block.timestamp;
        comment.text = text;
    }

    // function deleteComment(bytes32 postHash, uint256 commentId) external {
    //     bytes32 commentHash = _getCommentHash(postHash, commentId);

    //     require(commentRegistry[commentHash].user == msg.sender, 'NOT_COMMENT_CREATOR');
    //     delete commentRegistry[commentHash];
    // }

    function toggleLikeComment(bytes32 postHash, uint256 commentId) external requiresAccount {
        bytes32 commentHash = _getCommentHash(postHash, commentId);
        Comment storage comment = commentRegistry[commentHash];

        require(comment.user != msg.sender, 'CANNOT_LIKE_OWN_COMMENT');

        Account storage account = accounts[msg.sender];

        bool like = !account.likedComments[commentHash];

        account.likedComments[commentHash] = like;

        if (like) comment.numLikes++;
        else comment.numLikes--;
    }

    /* ----------------- Internal ----------------- */

    function _getCommentHash(bytes32 postHash, uint256 commentId) internal pure returns (bytes32) {
        return keccak256(abi.encode(postHash, commentId));
    }

    function _getComment(bytes32 postHash, uint256 commentId) internal view returns (Comment storage) {
        bytes32 commentHash = _getCommentHash(postHash, commentId);
        return commentRegistry[commentHash];
    }

    function _getCommentsByHashesHelper(bytes32[] memory commentHashes, address user)
        internal
        view
        returns (Comment[] memory)
    {
        Comment[] memory comments = new Comment[](commentHashes.length);
        for (uint256 i; i < commentHashes.length; i++) {
            comments[i] = commentRegistry[commentHashes[i]];
            comments[i].userName = accounts[comments[i].user].name;
            comments[i].liked = accounts[user].likedComments[commentHashes[i]];
        }
        return comments;
    }

    /* ----------------- View ----------------- */

    function getNumRegisteredUsers() external view returns (uint256) {
        return addressRegistry.length;
    }

    function getCommentsByPost(bytes32 postHash, address user) external view returns (Comment[] memory) {
        return _getCommentsByHashesHelper(commentHashesByPostHash[postHash], user);
    }

    function getCommentsByUser(address user) external view returns (Comment[] memory) {
        return _getCommentsByHashesHelper(accounts[user].commentHashes, user);
    }

    // function getUserAccount(address user) external view returns (Account memory) {
    //     return accounts[user];
    // }

    /* ----------------- Modifier ----------------- */

    modifier requiresAccount() {
        require(accounts[msg.sender].creationDate > 0, 'USER_ACCOUNT_REQUIRED');
        _;
    }
}

function isValidComment(string calldata text) pure returns (bool) {
    return bytes(text).length > 4 && bytes(text).length < 1000;
}

function isValidUserName(
    string calldata str,
    uint256 minLen,
    uint256 maxLen
) pure returns (bool) {
    bytes memory b = bytes(str);
    if (b.length < minLen || b.length > maxLen) return false;

    if (b[0] == 0x20) return false; // Leading space
    if (b[b.length - 1] == 0x20) return false; // Trailing space

    bytes1 lastChar = b[0];

    for (uint256 i; i < b.length; i++) {
        bytes1 char = b[i];

        if (
            (char > 0x60 && char < 0x7B) || //a-z
            (char == 0x20) || //space
            (char > 0x40 && char < 0x5B) || //A-Z
            (char > 0x2F && char < 0x3A) //9-0
        ) {
            lastChar = char;
        } else return false;
    }

    return true;
}
