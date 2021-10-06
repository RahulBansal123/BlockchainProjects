// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//Token Owners - Must possess token to vote.
//               Mapping of Struct for storing token ownership information.

//Proposals - Proposals to be voted on.
//            Mapping of Structs for storing proposal information.

contract Voting{
    address public owner;
    uint256 internal totalProposals;
    // uint256 public token_supply = 1000000;
    address private contract_address = 0x61175b02C97c13185ad10de68498b9874a7ce4a1; //On rinkeby, this is the address of the contract.
    mapping(address => uint256) private _balances;


    struct Voter{
        uint256 vote_choice;
        bool voted; 
    }
    
    struct Propsoal{
        uint256 vote_count;
        string proposal_text;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => Propsoal) public proposals;

    constructor() public{
        owner = msg.sender;
        totalProposals = 0;
    }

    modifier onlyOwner(){
        require(owner == msg.sender,'You are not an owner');
        _;
    }
    modifier onlyIfVoted(address _address){
        require(voters[_address].voted,'Not Voted yet!');
        _;
    }
    modifier canVote(address _address){
        require(_balances[_address] > 0,"You don't have voting tokens.");
        require(_address != owner,"You are not allowed to vote.");
        _;
    }


    function addProposal(string memory _proposal) public onlyOwner(){
        bool success = true;
        for(uint i=0; i<totalProposals; i++){
            if(keccak256(bytes(proposals[i].proposal_text))  ==  keccak256(bytes(_proposal))){
                success = false;
            }
        }
        require(success,"Proposal already exists.");
        proposals[totalProposals] = Propsoal(0,_proposal);
        totalProposals+=1;
    }

    function getProposal(uint256 _id) public view returns(string memory proposal_text){
        return proposals[_id].proposal_text;
    }

    function getVoterChoice(address _address) public view onlyIfVoted(_address) returns(uint256 _voteChoice){
        return voters[_address].vote_choice;
    }

    function giveTokens(address _address) public onlyOwner{
        _balances[_address] = 1;
    }

    function vote(uint256 _voteChoice) public canVote(msg.sender){
        voters[msg.sender].vote_choice = _voteChoice;
        voters[msg.sender].voted = true;
        _balances[msg.sender] = 0;
        proposals[_voteChoice].vote_count += 1;
    }

    function winner() public view returns(string memory _winner){
        uint256 winner_count = 0;
        string memory winner_name = "";

        for(uint256 i = 0; i < totalProposals; i++){
            if(proposals[i].vote_count > winner_count){
                winner_count = proposals[i].vote_count;
                winner_name = proposals[i].proposal_text;
            }
        }
        return winner_name;
    }
}