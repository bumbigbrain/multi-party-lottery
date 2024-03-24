// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
import "./CommitReveal.sol";


contract MPL is CommitReveal {

    struct Player {
        address addr;
        uint choice;
        bool isReveal;

    }

    address payable public owner;
    uint256 public t1;
    uint256 public t2;
    uint256 public t3;
    uint256 public t4;

    uint public n;
    uint public numPlayer;
    mapping (uint => Player) public player;
    uint public gameStage;
    uint public start_stage1;
    uint public start_stage2;
    
    

    constructor() {
        owner = payable(msg.sender);
        t1 = 30 seconds;
        t2 = 30 seconds;
        t3 = 1 minutes;
        t4 = 1 minutes;
        n = 3;
        numPlayer = 0;
        gameStage = 1;

    }


    
    function joinGame(uint choice) public payable { //register player  //add input : choice, salt
        require(msg.value == 1 ether, "You must pay 1 ether to play this game");
        require(numPlayer < n, "This game is full now"); 
        require(numPlayer == 0 || block.timestamp - start_stage1 <= t1);
        
        if (numPlayer == 0) {
            start_stage1 = block.timestamp;            
        }   
        player[numPlayer].addr = msg.sender;
        // need to hash choice before stored 
        player[numPlayer].choice = choice;
        player[numPlayer].isReveal = false;
        numPlayer++;
        
         
    }

    function startStage2() public onlyowner {
        require(block.timestamp > start_stage1 + t1, "Can't start Stage2");
        start_stage2 = block.timestamp;
    }


    function revealChoice(uint idx) public payable { // add input : choice, salt
        require(block.timestamp - start_stage2 <= t2, "Can't reveal now");
        // collect revealer
        require(msg.sender == player[idx].addr);
        player[idx].isReveal = true;

        //send choice to hash and compare the hash with hashed choice 
        
        
    }


    //function checkRevealer
    function checkRevealer(uint idx) public view returns(bool){
        return player[idx].isReveal;
    }


    function penalizeUser() public payable {

    }

    function getBalance(uint idx) public view returns(uint) {
        return player[idx].addr.balance;
    } // check



    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    } 


    
    
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


contract Lottery {

    struct Player {
        address addr;
        uint choice;
        bool isReveal;

    }

    address payable public owner;
    uint256 public t1;
    uint256 public t2;
    uint256 public t3;
    uint256 public t4;

    uint public n;
    uint public numPlayer;
    mapping (uint => Player) public player;
    uint public gameStage;
    uint public start_stage1;
    uint public start_stage2;
    
    

    constructor() {
        owner = payable(msg.sender);
        t1 = 30 seconds;
        t2 = 30 seconds;
        t3 = 1 minutes;
        t4 = 1 minutes;
        n = 3;
        numPlayer = 0;
        gameStage = 1;

    }


    
    function joinGame(uint choice) public payable { //register player  //add input : choice, salt
        require(msg.value == 1 ether, "You must pay 1 ether to play this game");
        require(numPlayer < n, "This game is full now"); 
        require(numPlayer == 0 || block.timestamp - start_stage1 <= t1);
        
        if (numPlayer == 0) {
            start_stage1 = block.timestamp;            
        }   
        player[numPlayer].addr = msg.sender;
        // need to hash choice before stored 
        player[numPlayer].choice = choice;
        player[numPlayer].isReveal = false;
        numPlayer++;
        
         
    }

    function startStage2() public onlyowner {
        require(block.timestamp > start_stage1 + t1, "Can't start Stage2");
        start_stage2 = block.timestamp;
    }


    function revealChoice(uint idx) public payable { // add input : choice, salt
        require(block.timestamp - start_stage2 <= t2, "Can't reveal now");
        // collect revealer
        require(msg.sender == player[idx].addr);
        player[idx].isReveal = true;

        //send choice to hash and compare the hash with hashed choice 
        
        
    }

    //function checkRevealer
    function checkRevealer(uint idx) public view returns(bool){
        return player[idx].isReveal;
    }


    function penalizeUser() public payable {
        
    }



    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    } 


    
    
}