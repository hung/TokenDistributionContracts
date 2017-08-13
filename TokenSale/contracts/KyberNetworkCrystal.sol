pragma solidity ^0.4.11;

//import 'zeppelin-solidity/contracts/token/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/ownership/HasNoTokens.sol';




// TODO - check is already released in next solidity version
/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint _value)
        public
    {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);
}


contract KyberNetworkCrystal is BurnableToken, MintableToken, HasNoTokens {
    string  public  constant name = "Kyber Network Crystal";
    string  public  constant symbol = "KNC";
    uint    public  constant decimals = 18;
    
    uint    public  saleStartTime;
    uint    public  saleEndTime;
    
    address public  tokenSaleContract;

    modifier onlyWhenTransferEnabled() {
        if( now >= saleStartTime && now <= saleEndTime ) {
            require( msg.sender == tokenSaleContract );
        }
        _;
    }

    function KyberNetworkCrystal( uint tokenTotalAmount, uint startTime, uint endTime, address admin ) {    
        // Mint all tokens. Then disable minting forever.
        assert( mint( msg.sender, tokenTotalAmount ) );
        assert( finishMinting() );
        
        saleStartTime = startTime;
        saleEndTime = endTime;
        
        tokenSaleContract = msg.sender;
        transferOwnership(admin); // admin could drain tokens that were sent here by mistake
    }
    
    // save some gas by making only one contract call
    function burnFrom(address _from, uint256 _value) onlyWhenTransferEnabled {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }
    
    function transfer(address _to, uint256 _value) onlyWhenTransferEnabled returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyWhenTransferEnabled returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }    
}