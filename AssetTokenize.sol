pragma solidity >=0.6.0 <0.9.0;

contract RealEstateToken {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string public name = "Real Estate Token";
    string public symbol = "RET";
    uint8 public decimals = 0;

    uint256 private _totalSupply;

    address public owner;
    bool public isPropertyTokenized = false;

    struct Property {
        string location;
        uint256 value;      //property's value
        bool isTokenized;
    }

    Property public property;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event PropertyTokenized(string location, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(string memory _location, uint256 _value) {
        owner = msg.sender;
        property.location = _location;
        property.value = _value;
        property.isTokenized = false;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_balances[msg.sender] >= _value, "Insufficient balance");
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= _balances[_from], "Insufficient balance");
        require(_value <= _allowed[_from][msg.sender], "Insufficient allowance");
        _balances[_from] -= _value;
        _balances[_to] += _value;
        _allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function tokenizeProperty(uint256 _tokens) public onlyOwner {
        require(!isPropertyTokenized, "Property already tokenized");
        require(_tokens > 0, "Token amount must be greater than zero");

        _totalSupply += _tokens;
        _balances[owner] += _tokens;
        property.isTokenized = true;
        isPropertyTokenized = true;

        emit PropertyTokenized(property.location, property.value);
        emit Transfer(address(0), owner, _tokens);
    }

    function setProperty(string memory _location, uint256 _value) public onlyOwner {
        require(!isPropertyTokenized, "Property already tokenized");
        property.location = _location;
        property.value = _value;
    }
}
