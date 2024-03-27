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
    uint public start_stage1 = 0;
    bool canRefund = true;
    
    

    constructor(uint time1, uint time2, uint time3, uint n_player) {
        owner = payable(msg.sender);
        t1 = time1;
        t2 = time2;
        t3 = time3;
        //t4 = 1 minutes;
        n = n_player;
        numPlayer = 0;
        

    }



    function getHashedChoice(uint choice, uint salt) public view returns(bytes32) {
        return getSaltedHash(bytes32(choice), bytes32(salt));

    }


    function checkState() public view returns(string memory) {

        if (start_stage1 == 0){
            return "Not started";
        }
        
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
        require(msg.value == 0.001 ether, "You must pay 0.001 ether to play this game");
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




    function revealChoice(uint choice, uint salt, uint idx) public { // add input : choice, salt
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



    function _findPlayerNotRevealAndRefund() private {
        for (uint256 i = 0; i < numPlayer; i ++) {
            if (player[i].passedReveal == false) {
                uint256 toPayOwner = 0.001 ether * 2 / 100;
                payable(owner).transfer(toPayOwner);
                payable(player[i].addr).transfer(0.001 ether - toPayOwner);
            }
        }
    }


    function findWinner() public onlyowner {
        require(start_stage1 + t1 + t2 <= block.timestamp && block.timestamp <= start_stage1 + t1 + t2 + t3, checkState());
        uint256 result = 0;


        _findPlayerNotRevealAndRefund();
        
        for (uint256 i = 0; i < numPlayer; i++){
            if (player[i].passedReveal && (player[i].realChoice >= 0 && player[i].realChoice <= 999)) {
                result = result ^ player[i].realChoice;
            }
        }
        
        uint256 winnerIdx = uint256(keccak256(abi.encodePacked(result))) % numPlayer;


        if (player[winnerIdx].passedReveal) {
            uint256 qwe = (0.001 ether * 98 * numPlayer) / 100;
            payable(player[winnerIdx].addr).transfer(qwe);
            qwe = (0.001 ether * 2 * numPlayer) / 100;
            payable(owner).transfer(qwe);
        } else {
            payable(owner).transfer(address(this).balance);
        }
        canRefund = false;
        _restart();
    }

    function refund() public payable {
        require(canRefund && (start_stage1 + t1 + t2 + t3 <= block.timestamp), checkState());
        require(msg.sender != owner);
        payable(msg.sender).transfer(0.001 ether);
        if (address(this).balance == 0) {
            _restart();
        }
    }

    
    function _restart() private {
        start_stage1 = 0;
        numPlayer = 0;
        
        for (uint i = 0; i < n; i++){
            delete player[i];
            delete commits[player[i].addr];
        }

        
    }

    
    


    

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    } 


    
    
}