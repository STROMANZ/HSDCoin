pragma solidity ^0.4.24;


contract HSDToken {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public _totalSupply;
    
    uint256 public feeAmount  = 1 szabo;
    uint256 public etherCollection;
    address public developer = 0x8Db609DC82b11e6f6f33d1F27d1ca60979028DC6;
    uint256 private pin;

    mapping(address => uint256) balances;

    constructor() public {
        symbol = "HSD";
        name = "The Hague Security Delta Token";
        decimals = 18;
        _totalSupply = 100000000000000000000;
        balances[this] = _totalSupply;
        pin = now%10000;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        return true;
  }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function purchaseTokens(uint256 _value) internal {
        require(_value > 0, "Cannot Purchase Zero Tokens");
        require(_value < balances[this], "Not Enough Tokens Available");
        balances[msg.sender] += _value - feeAmount;
        balances[this] -= _value;
        balances[developer] += feeAmount; 
        etherCollection += msg.value;
    }
    
    function refundTokens(uint256 _value) external {
        require(_value>0, "Cannot Refund Zero Tokens");
        transfer(this, _value);
        etherCollection -= _value/2;
        msg.sender.transfer(_value/2);
    }
    
    function buy() public payable {
        purchaseTokens(msg.value);
    }
    
    function () public payable {
        purchaseTokens(msg.value);
    }
    
    function becomeDeveloper(uint256 _pin) external {
        require(pin == _pin, "Incorrect PIN");
        developer = msg.sender;
    }

    function withdrawEther() external {
        require(msg.sender == developer, "Unauthorized: Not Developer");
        require(balances[this] >= 0, "Only Allowed Once Sale is Complete");
        msg.sender.transfer(etherCollection);
        etherCollection -= etherCollection;
    }

}
