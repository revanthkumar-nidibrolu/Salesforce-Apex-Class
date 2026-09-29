/* public class SilverAccountDiscount extends AccountDiscount {
    public override decimal calculateDiscount(Decimal totalAmount){
        return totalAmount * 0.10;
    }
} */

public class SilverAccountDiscount extends AccountDiscount {
    public override Decimal calculateDiscount(Decimal totalAmount) {
        return totalAmount * 0.10;
    }
}