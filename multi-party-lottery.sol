// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
import "./CommitReveal.sol";

contract MPL is CommitReveal {

    struct Player {
        address addr;
        bytes32 choice;
        bool passedReveal;
        uint realChoice;

    }

    address payable public owner;
    uint256 public t1;
    uint256 public t2;
    uint256 public t3;
    uint256 public t4;

    uint256 public n;
    uint public numPlayer;
    mapping (uint => Player) public player;
    uint public start_stage1;
    bool canRefund = true;
    
    

    constructor() {
        owner = payable(msg.sender);
        t1 = 1 minutes;
        t2 = 1 minutes;
        t3 = 1 minutes;
        //t4 = 1 minutes;
        n = 3;
        numPlayer = 0;

    }



    function getHashedChoice(uint choice, uint salt) public view returns(bytes32) {
        return getSaltedHash(bytes32(choice), bytes32(salt));

    }


    function checkState() public view returns(string memory) {
        
        if (start_stage1 <= block.timestamp && block.timestamp <= start_stage1 + t1) {
            return "Now Stage : Stage 1";
        }

        if (start_stage1 + t1 <= block.timestamp && block.timestamp <= start_stage1 + t1 + t2) {
            return "Now Stage : Stage 2";
        }

        if (start_stage1 + t1 + t2 <= block.timestamp && block.timestamp <= start_stage1 + t1 + t2 + t3) {
            return "Now Stage : Stage 3";
        }

        if (start_stage1 + t1 + t2 + t3 <= block.timestamp) {
            return "Now Stage : Stage 4";
        }

        return "Not started";
    }


    
    function joinGame(bytes32 hashedChoice) public payable { //register player 
        require(msg.value == 1 ether, "You must pay 1 ether to play this game");
        require(numPlayer < n, "This game is full now"); 
        require(numPlayer == 0 || block.timestamp - start_stage1 <= t1, checkState());
        
        if (numPlayer == 0) {
            start_stage1 = block.timestamp;            
        }   
        player[numPlayer].addr = msg.sender;
        commit(hashedChoice);
        player[numPlayer].choice = hashedChoice;
        player[numPlayer].passedReveal = false;
        numPlayer++;
        
    }




    function revealChoice(uint choice, uint salt, uint idx) public payable { // add input : choice, salt
        require(start_stage1 + t1 <= block.timestamp && block.timestamp <= start_stage1 + t1 + t2, checkState());
        require(msg.sender == player[idx].addr);
        revealAnswer(bytes32(choice), bytes32(salt));
        player[idx].passedReveal = true;
        player[idx].realChoice = choice;
        
    }


    function seeCommited(uint idx) public view returns(bytes32) {
        return commits[player[idx].addr].commit;
    }


    function checkRevealer(uint idx) public view returns(bool){
        return player[idx].passedReveal;
    }



    function getBalanceContract() public view returns(uint256) {
        return address(this).balance;
    }


    function findWinner() public payable {
        require(start_stage1 + t1 + t2 <= block.timestamp && block.timestamp <= start_stage1 + t1 + t2 + t3, checkState());
        uint result = 0;
        
        for (uint i = 0; i < n; i++){
            if (player[i].passedReveal && (player[i].realChoice >= 0 && player[i].realChoice <= 999)) {
                result = result ^ player[i].realChoice;
            }
        }
        
        result = result % n;
        if (player[result].passedReveal) {
            uint256 qwe = 1 ether * 98;
            qwe = qwe/100;
            payable(player[result].addr).transfer(qwe);
            uint256 balance = getBalanceContract();
            payable(owner).transfer(balance - qwe);
        } else {
            payable(owner).transfer(address(this).balance);
        }
        canRefund = false;
        
    }

    function refund() public payable {
        require(canRefund && (start_stage1 + t1 + t2 + t3 <= block.timestamp), checkState());
        payable(msg.sender).transfer(1 ether);
    }

    
    