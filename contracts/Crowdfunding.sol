// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


contract Crowdfunding{

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping (address=>bool) voters;
    }


mapping(address=>uint) public contributors;
mapping(uint=>Request)  public requests;
uint public numRequests;
address public manager;
uint public minimumContribution;
uint public deadline;
uint public target;
uint public raisedAmount;
uint public noOfContributors;




constructor(uint _target, uint _deadline){
    manager=msg.sender;
    target=_target;
    deadline=block.timestamp+_deadline;
    minimumContribution=100 wei;
    

}

modifier onlyManager{
    require(manager==msg.sender,"You are not Owner");
    _;
}

function createRequests(string calldata _description,address payable _recipient,uint _value) public onlyManager {
    Request storage newRequest = requests[numRequests];
    numRequests++;
    newRequest.description=_description;
    newRequest.recipient=_recipient;
    newRequest.value=_value;
    newRequest.completed=false;
    newRequest.noOfVoters=0;
}

function contribution() public payable {
    require(block.timestamp<deadline,"Deadline has passed");
    require(msg.value>=minimumContribution,"Minimum Contribution Required is 100wei");

    if (contributors[msg.sender]==0){
        noOfContributors++;
    }
    contributors[msg.sender] = contributors[msg.sender] + msg.value;
    raisedAmount += msg.value; 

}

function getContractBalance() public  view returns(uint){
    return address(this).balance;
}

function refund() public{
    require(block.timestamp>deadline && raisedAmount<target,"You are not elgibile for refund");
    require(contributors[msg.sender]>0,"You are not contributor");
    payable(msg.sender).transfer(contributors[msg.sender]);
    contributors[msg.sender]=0;

}

function voteRequest(uint _requestNo) public {
    require(contributors[msg.sender]>0,"You are not contributor");

    Request storage thisRequest = requests[_requestNo];
    require(thisRequest.voters[msg.sender]==false,"You have already voted");
thisRequest.voters[msg.sender]=true;
thisRequest.noOfVoters++;

}

function makePayment(uint _requestNo) public onlyManager {
    require(raisedAmount>target,"Target is not reached");
    Request storage thisRequest=requests[_requestNo];
    require(thisRequest.completed==false,"The request has been completed");
    require(thisRequest.noOfVoters>noOfContributors/2,"Majority does not  support the request");
    thisRequest.recipient.transfer(thisRequest.value);
    thisRequest.completed=true;
}


}