OWNER CAN ADJUST PARAMETER(t1, t2, t3, n) BEFORE DEPLOY AT constructor()
PLAYER CAN HASH THEIR CHOICE BY USING getHashedChoice(uint choice, uint salt)

STAGE 1 :
  - player hash their choice by using getHashedChoice(uint choice, uint salt) and pass through joinGame(bytes32 hashedChoice) to commit input

STAGE 2:
  - player reveal their choice by using revealChoice(uint choice, uint salt, uint idx) (note : idx is index of player) 

STAGE 3:
  - owner find the winner by using findWinner()
  - if owner not use findWinner() in time, the contract will move to STAGE 4 

STAGE 4:
  - player can refund by using refund()

