// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract PollContract {
    struct Poll {
        uint256 id;
        string question;
        string image;
        uint64[] votes;
        bytes32[] options;
    }

    struct Voter {
        address id;
        uint256[] votedIds;
        mapping(uint256 => bool) votedMap;
    }

    Poll[] private polls;
    mapping(address => Voter) private voters;

    event PollCreated(uint256 _pollId);

    function createPoll(
        string memory _question,
        string memory _image,
        bytes32[] memory _options
    ) public {
        require(bytes(_question).length > 0, "Empty question");
        require(_options.length > 1, "At least 2 options are required");

        uint256 pollId = polls.length; // eek...

        Poll memory newPoll = Poll({
            id: pollId,
            question: _question,
            image: _image,
            options: _options,
            votes: new uint64[](_options.length)
        });

        polls.push(newPoll);
        emit PollCreated(pollId);
    }

    function getPoll(uint256 _pollId)
        external
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint64[] memory,
            bytes32[] memory
        )
    {
        require(_pollId < polls.length && _pollId >= 0, "No poll found");

        Poll memory poll = polls[_pollId];
        return (poll.id, poll.question, poll.image, poll.votes, poll.options);
    }

    function vote(uint256 _pollId, uint256 _vote) external {
        require(_pollId < polls.length, "Poll does not exist");
        require(_vote < polls[_pollId].options.length, "Invalid vote");
        require(
            voters[msg.sender].votedMap[_pollId] == false,
            "You already voted"
        );

        polls[_pollId].votes[_vote] += 1;
        voters[msg.sender].votedIds.push(_pollId);
        voters[msg.sender].votedMap[_pollId] = true;
    }

    function getVoter(address _id)
        external
        view
        returns (address, uint256[] memory)
    {
        return (voters[_id].id, voters[_id].votedIds);
    }

    function getPollCount() external view returns (uint256) {
        return polls.length;
    }
}
