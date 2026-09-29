public class StandardAccountDiscount extends AccountDiscount {
    public override Decimal calculateDiscount(Decimal totalAmount) {
        return totalAmount * 0.05;
    }
}