/* public class GoldAccountDiscount extends AccountDiscount {
    public override decimal calculateDiscount(Decimal totalAmount){
        return totalAmount * 0.20;
    }
} */

public class GoldAccountDiscount extends AccountDiscount {
    public override Decimal calculateDiscount(Decimal totalAmount) {
        return totalAmount * 0.20;
    }
}